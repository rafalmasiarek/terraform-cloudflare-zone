locals {
  zone_id        = cloudflare_zone.this.id
  global_comment = trimspace(var.comment) != "" ? var.comment : null

  rulesets_by_key = {
    for ruleset in var.rulesets : ruleset.key => ruleset
  }

  zone_settings_by_id = {
    for setting in var.zone_settings : setting.setting_id => setting
  }

  helper_spf_all_map = {
    allow    = "+all"
    fail     = "-all"
    neutral  = "?all"
    softfail = "~all"
  }

  helper_dmarc_alignment_map = {
    relaxed = "r"
    strict  = "s"
  }

  mx_records = var.mx == null ? [] : flatten([
    for name in coalesce(try(var.mx.names, null), ["@"]) : [
      for server in var.mx.servers : {
        record_name = format(
          "helper-mx-%s-%05d-%s",
          replace(lower(name), "@", "root"),
          server.priority,
          substr(sha1(lower(server.host)), 0, 10)
        )
        type     = "MX"
        name     = name
        value    = server.host
        comment  = coalesce(try(var.mx.comment, null), local.global_comment)
        priority = server.priority
        ttl      = try(var.mx.ttl, null)
        proxied  = false
      }
    ]
  ])

  spf_terms = var.spf == null ? [] : concat(
    ["v=spf1"],
    [for include in coalesce(try(var.spf.includes, null), []) : "include:${include}"],
    [for ip4 in coalesce(try(var.spf.ip4s, null), []) : "ip4:${ip4}"],
    [for ip6 in coalesce(try(var.spf.ip6s, null), []) : "ip6:${ip6}"],
    try(var.spf.a, false) ? ["a"] : [],
    try(var.spf.mx, false) ? ["mx"] : [],
    try(var.spf.redirect, null) != null ? ["redirect=${var.spf.redirect}"] : [],
    [local.helper_spf_all_map[try(var.spf.all, "fail")]]
  )

  spf_records = var.spf == null ? [] : [
    {
      record_name = format(
        "helper-spf-%s",
        replace(lower(try(var.spf.name, "@")), "@", "root")
      )
      type     = "TXT"
      name     = try(var.spf.name, "@")
      value    = join(" ", local.spf_terms)
      comment  = coalesce(try(var.spf.comment, null), local.global_comment)
      priority = null
      ttl      = try(var.spf.ttl, null)
      proxied  = false
    }
  ]

  dmarc_parts = var.dmarc == null ? [] : concat(
    [
      "v=DMARC1;",
      "p=${var.dmarc.policy};",
      "pct=${try(var.dmarc.percent, 100)};",
      "aspf=${local.helper_dmarc_alignment_map[try(var.dmarc.spf_mode, "relaxed")]};",
      "adkim=${local.helper_dmarc_alignment_map[try(var.dmarc.dkim_mode, "relaxed")]};"
    ],
    try(var.dmarc.subdomain_policy, null) != null ? ["sp=${var.dmarc.subdomain_policy};"] : [],
    length(coalesce(try(var.dmarc.rua, null), [])) > 0 ? ["rua=${join(",", coalesce(try(var.dmarc.rua, null), []))};"] : [],
    length(coalesce(try(var.dmarc.ruf, null), [])) > 0 ? ["ruf=${join(",", coalesce(try(var.dmarc.ruf, null), []))};"] : [],
    try(var.dmarc.fo, null) != null ? ["fo=${var.dmarc.fo};"] : []
  )

  dmarc_records = var.dmarc == null ? [] : [
    {
      record_name = "helper-dmarc"
      type        = "TXT"
      name        = "_dmarc"
      value       = join(" ", local.dmarc_parts)
      comment     = coalesce(try(var.dmarc.comment, null), local.global_comment)
      priority    = null
      ttl         = try(var.dmarc.ttl, null)
      proxied     = false
    }
  ]

  tlsrpt_records = var.tlsrpt == null ? [] : [
    {
      record_name = "helper-tlsrpt"
      type        = "TXT"
      name        = "_smtp._tls"
      value       = format("v=TLSRPTv1; rua=%s", join(",", var.tlsrpt.rua))
      comment     = coalesce(try(var.tlsrpt.comment, null), local.global_comment)
      priority    = null
      ttl         = try(var.tlsrpt.ttl, null)
      proxied     = false
    }
  ]

  dkim_records = var.dkim == null ? [] : [
    for selector, cfg in var.dkim : {
      record_name = format(
        "helper-dkim-%s-%s",
        replace(lower(selector), "_", "-"),
        lower(cfg.type)
      )
      type     = upper(cfg.type)
      name     = format("%s._domainkey", selector)
      value    = upper(cfg.type) == "TXT" ? format("v=DKIM1; k=%s; p=%s", try(cfg.key_type, "rsa"), cfg.public_key) : cfg.target
      comment  = coalesce(try(cfg.comment, null), local.global_comment)
      priority = null
      ttl      = try(cfg.ttl, null)
      proxied  = false
    }
  ]

  all_records = concat(
    var.records,
    local.mx_records,
    local.spf_records,
    local.dmarc_records,
    local.tlsrpt_records,
    local.dkim_records,
  )

  all_records_normalized = [
    for record in local.all_records : merge(record, {
      name = (
        try(record.name, null) == null || trimspace(record.name) == "" || trimspace(record.name) == "@"
        ? "@"
        : (
          lower(trimspace(record.name)) == lower(var.zone) ||
          endswith(lower(trimspace(record.name)), ".${lower(var.zone)}")
          ? trimspace(record.name)
          : "${trimspace(record.name)}.${var.zone}"
        )
      )

      value = try(record.value, null) == null ? null : (
        upper(record.type) != "TXT"
        ? record.value
        : (
          can(regex("^\".*\"$", trimspace(record.value)))
          ? record.value
          : join(" ", [
            for chunk in chunklist(split("", record.value), 255) :
            "\"${join("", chunk)}\""
          ])
        )
      )
    })
  ]

  all_records_by_key = {
    for record in local.all_records_normalized : record.record_name => record
  }
}

resource "cloudflare_zone" "this" {
  account = {
    id = var.account_id
  }

  name   = var.zone
  paused = var.paused
  type   = var.type
}

resource "cloudflare_zone_dnssec" "this" {
  count = var.enable_dnssec ? 1 : 0

  zone_id = local.zone_id
}

resource "cloudflare_dns_record" "this" {
  for_each = local.all_records_by_key

  zone_id = local.zone_id

  name    = coalesce(each.value.name, "@")
  type    = each.value.type
  content = each.value.value
  comment = coalesce(try(each.value.comment, null), local.global_comment)
  data    = each.value.value == null ? try(each.value.data, null) : null

  priority = try(each.value.priority, null)
  proxied  = coalesce(try(each.value.proxied, null), false)
  ttl      = coalesce(try(each.value.ttl, null), 1)
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.zone_settings_by_id

  zone_id    = local.zone_id
  setting_id = each.value.setting_id
  value      = try(each.value.value, null)
  enabled    = try(each.value.enabled, null)
}

resource "cloudflare_ruleset" "this" {
  for_each = local.rulesets_by_key

  zone_id    = coalesce(try(each.value.account_level, null), false) ? null : local.zone_id
  account_id = coalesce(try(each.value.account_level, null), false) ? var.account_id : null

  name        = each.value.name
  description = try(each.value.description, null)
  kind        = each.value.kind
  phase       = each.value.phase

  rules = [
    for rule in coalesce(try(each.value.rules, null), []) : {
      ref         = rule.ref
      action      = rule.action
      expression  = try(rule.expression, null)
      description = try(rule.description, null)
      enabled     = try(rule.enabled, true)

      action_parameters = try(rule.action_parameters, null) != null ? {
        cache                      = try(rule.action_parameters.cache, null)
        origin_error_page_passthru = try(rule.action_parameters.origin_error_page_passthru, null)
        respect_strong_etags       = try(rule.action_parameters.respect_strong_etags, null)
        version                    = try(rule.action_parameters.version, null)

        response = try(rule.action_parameters.response, null) != null ? {
          status_code  = try(rule.action_parameters.response.status_code, null)
          content      = try(rule.action_parameters.response.content, null)
          content_type = try(rule.action_parameters.response.content_type, null)
        } : null

        from_value = try(rule.action_parameters.from_value, null) != null ? {
          status_code           = try(rule.action_parameters.from_value.status_code, null)
          preserve_query_string = try(rule.action_parameters.from_value.preserve_query_string, null)

          target_url = try(rule.action_parameters.from_value.target_url, null) != null ? {
            value      = try(rule.action_parameters.from_value.target_url.value, null)
            expression = try(rule.action_parameters.from_value.target_url.expression, null)
          } : null
        } : null

        edge_ttl = try(rule.action_parameters.edge_ttl, null) != null ? {
          mode    = rule.action_parameters.edge_ttl.mode
          default = try(rule.action_parameters.edge_ttl.default, null)

          status_code_ttl = [
            for status_code_ttl in coalesce(try(rule.action_parameters.edge_ttl.status_code_ttl, null), []) : {
              status_code = try(status_code_ttl.status_code, null)

              status_code_range = try(status_code_ttl.status_code_range, null) != null ? {
                from = status_code_ttl.status_code_range.from
                to   = status_code_ttl.status_code_range.to
              } : null

              value = status_code_ttl.value
            }
          ]
        } : null

        browser_ttl = try(rule.action_parameters.browser_ttl, null) != null ? {
          mode    = rule.action_parameters.browser_ttl.mode
          default = try(rule.action_parameters.browser_ttl.default, null)
        } : null

        serve_stale = try(rule.action_parameters.serve_stale, null) != null ? {
          disable_stale_while_updating = try(rule.action_parameters.serve_stale.disable_stale_while_updating, null)
        } : null

        cache_key = try(rule.action_parameters.cache_key, null) != null ? {
          ignore_query_strings_order = try(rule.action_parameters.cache_key.ignore_query_strings_order, null)
          cache_by_device_type       = try(rule.action_parameters.cache_key.cache_by_device_type, null)
        } : null

        uri = try(rule.action_parameters.uri, null) != null ? {
          path = try(rule.action_parameters.uri.path, null) != null ? {
            value      = try(rule.action_parameters.uri.path.value, null)
            expression = try(rule.action_parameters.uri.path.expression, null)
          } : null
        } : null

        headers = try(rule.action_parameters.headers, null) != null ? {
          for name, header in rule.action_parameters.headers : name => {
            operation  = header.operation
            value      = try(header.value, null)
            expression = try(header.expression, null)
          }
        } : null

        host_header = try(rule.action_parameters.host_header, null)
      } : null

      logging = try(rule.logging, null) != null ? {
        enabled = rule.logging.enabled
      } : null

      ratelimit = try(rule.ratelimit, null) != null ? {
        characteristics            = rule.ratelimit.characteristics
        period                     = rule.ratelimit.period
        requests_per_period        = rule.ratelimit.requests_per_period
        mitigation_timeout         = rule.ratelimit.mitigation_timeout
        requests_to_origin         = try(rule.ratelimit.requests_to_origin, null)
        score_per_period           = try(rule.ratelimit.score_per_period, null)
        score_response_header_name = try(rule.ratelimit.score_response_header_name, null)
        counting_expression        = try(rule.ratelimit.counting_expression, null)
      } : null

      exposed_credential_check = try(rule.exposed_credential_check, null) != null ? {
        username_expression = rule.exposed_credential_check.username_expression
        password_expression = rule.exposed_credential_check.password_expression
      } : null
    }
  ]
}
