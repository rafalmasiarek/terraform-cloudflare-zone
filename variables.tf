variable "account_id" {
  type        = string
  description = "Account ID to manage the zone resource in. You can get more information on how to find `account_id` at [this page](https://developers.cloudflare.com/fundamentals/get-started/basic-tasks/find-account-and-zone-ids/)."
}

variable "zone" {
  type        = string
  description = "The DNS zone name which will be added, e.g. example.com."
}

variable "zone_settings" {
  type = list(object({
    setting_id = string
    value      = optional(string)
    enabled    = optional(bool)
  }))
  default     = []
  description = <<-EOT
    Zone settings applied with `cloudflare_zone_setting`.

    Some settings use `value`, while others use `enabled`.
  EOT

  validation {
    condition = length(var.zone_settings) == length(distinct([
      for s in var.zone_settings : s.setting_id
    ]))
    error_message = "Each zone setting_id must be unique."
  }

  validation {
    condition = alltrue([
      for s in var.zone_settings : length(trimspace(s.setting_id)) > 0
    ])
    error_message = "Each zone setting must define a non-empty setting_id."
  }
}

variable "paused" {
  type        = bool
  default     = false
  description = "Indicates if the zone is only using Cloudflare DNS services. A true value means the zone will not receive security or performance benefits."
}

variable "type" {
  type        = string
  default     = "full"
  description = <<-EOT
    A full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup. Possible values: `full`, `partial`.
    To learn more and choose the right configuration for you, see the documentation about [full](https://developers.cloudflare.com/dns/zone-setups/full-setup/) or [partial CNAME](https://developers.cloudflare.com/dns/zone-setups/partial-setup/) setups.
  EOT
}

variable "enable_dnssec" {
  type        = bool
  default     = false
  description = "Enable or disable DNSSEC."
}

variable "records" {
  type = list(object({
    record_name = string
    type        = string
    name        = optional(string)
    value       = optional(string)
    comment     = optional(string)
    data = optional(object({
      algorithm      = optional(number)
      altitude       = optional(number)
      certificate    = optional(string)
      content        = optional(string)
      digest         = optional(string)
      digest_type    = optional(number)
      fingerprint    = optional(string)
      flags          = optional(string)
      key_tag        = optional(number)
      lat_degrees    = optional(number)
      lat_direction  = optional(string)
      lat_minutes    = optional(number)
      lat_seconds    = optional(number)
      long_degrees   = optional(number)
      long_direction = optional(string)
      long_minutes   = optional(number)
      long_seconds   = optional(number)
      matching_type  = optional(number)
      name           = optional(string)
      order          = optional(number)
      port           = optional(number)
      precision_horz = optional(number)
      precision_vert = optional(number)
      preference     = optional(number)
      priority       = optional(number)
      proto          = optional(string)
      protocol       = optional(number)
      public_key     = optional(string)
      regex          = optional(string)
      replacement    = optional(string)
      selector       = optional(number)
      service        = optional(string)
      size           = optional(number)
      tag            = optional(string)
      target         = optional(string)
      type           = optional(number)
      usage          = optional(number)
      value          = optional(string)
      weight         = optional(number)
    }))
    priority = optional(number)
    ttl      = optional(number)
    proxied  = optional(bool)
  }))
  default     = []
  description = <<-EOT
    Zone's raw DNS records.

    Use this input for records that are not covered by dedicated helpers.
    Possible values:
      * for the `type` argument: "A", "AAAA", "CAA", "CERT", "CNAME", "DNSKEY", "DS", "HTTPS", "LOC", "MX", "NAPTR", "NS", "PTR", "SMIMEA", "SPF", "SRV", "SSHFP", "SVCB", "TLSA", "TXT", "URI".
      * for the `priority` argument: between 0 and 65535.
      * possible values for the `ttl` argument: between 60 and 86400, or 1 for automatic.
      * `comment` is an optional Cloudflare DNS record comment.
  EOT

  validation {
    condition = length(var.records) == length(distinct([
      for r in var.records : r.record_name
    ]))
    error_message = "Each raw record_name must be unique."
  }

  validation {
    condition = alltrue([
      for i in var.records : try(i.value != null || i.data != null)
    ])
    error_message = "Either the value or the data must be provided for each raw record."
  }

  validation {
    condition = alltrue([
      for i in var.records : try(i.ttl == 1 || i.ttl >= 60 && i.ttl <= 86400, true)
    ])
    error_message = "The ttl values must be between 60 and 86400, or 1 for automatic."
  }

  validation {
    condition = alltrue([
      for i in var.records : try(i.priority >= 0 && i.priority <= 65535, true)
    ])
    error_message = "The priority values must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for i in var.records : try(i.type == "MX" ? i.priority != null : true)
    ])
    error_message = "The priority must not be null for each raw record of type \"MX\"."
  }
}

variable "mx" {
  type = object({
    names = optional(list(string), ["@"])
    servers = list(object({
      host     = string
      priority = number
    }))
    ttl     = optional(number)
    comment = optional(string)
  })
  default     = null
  description = <<-EOT
    Helper for MX records.

    The helper creates one MX record for each combination of `names` and `servers`.
    Example:

    ```hcl
    mx = {
      names = ["@", "mail"]
      servers = [
        {
          host     = "mx1.provider.com"
          priority = 10
        },
        {
          host     = "mx2.provider.com"
          priority = 20
        }
      ]
    }
    ```
  EOT

  validation {
    condition     = var.mx == null ? true : length(var.mx.servers) > 0
    error_message = "The mx helper must define at least one server."
  }

  validation {
    condition = var.mx == null ? true : alltrue([
      for name in try(var.mx.names, ["@"]) : length(trimspace(name)) > 0
    ])
    error_message = "Each mx helper name must be non-empty. Use \"@\" for the zone apex."
  }

  validation {
    condition = var.mx == null ? true : alltrue([
      for server in var.mx.servers :
      length(trimspace(server.host)) > 0 && server.priority >= 0 && server.priority <= 65535
    ])
    error_message = "Each mx helper server must define a non-empty host and a priority between 0 and 65535."
  }

  validation {
    condition     = var.mx == null ? true : try(var.mx.ttl == null || var.mx.ttl == 1 || var.mx.ttl >= 60 && var.mx.ttl <= 86400, true)
    error_message = "The mx helper ttl must be between 60 and 86400, or 1 for automatic."
  }
}

variable "spf" {
  type = object({
    name     = optional(string, "@")
    includes = optional(list(string), [])
    ip4s     = optional(list(string), [])
    ip6s     = optional(list(string), [])
    a        = optional(bool, false)
    mx       = optional(bool, false)
    redirect = optional(string)
    all      = optional(string, "fail")
    ttl      = optional(number)
    comment  = optional(string)
  })
  default     = null
  description = <<-EOT
    Helper for an SPF TXT record.

    This helper is semantic: instead of passing raw SPF terms, provide inputs such as
    `includes`, `ip4s`, `ip6s`, `a`, `mx`, `redirect` and `all`.

    Example:

    ```hcl
    spf = {
      includes = ["_spf.google.com", "spf.mailgun.org"]
      ip4s     = ["192.0.2.10", "198.51.100.0/24"]
      all      = "softfail"
    }
    ```
  EOT

  validation {
    condition     = var.spf == null ? true : contains(["allow", "fail", "neutral", "softfail"], var.spf.all)
    error_message = "The spf helper all value must be one of: allow, fail, neutral, softfail."
  }

  validation {
    condition     = var.spf == null ? true : length(trimspace(try(var.spf.name, "@"))) > 0
    error_message = "The spf helper name must be non-empty. Use \"@\" for the zone apex."
  }

  validation {
    condition = var.spf == null ? true : alltrue([
      for include in try(var.spf.includes, []) : length(trimspace(include)) > 0
    ])
    error_message = "Each spf helper include must be non-empty and must not include surrounding whitespace."
  }

  validation {
    condition = var.spf == null ? true : alltrue([
      for ip in concat(try(var.spf.ip4s, []), try(var.spf.ip6s, [])) : length(trimspace(ip)) > 0
    ])
    error_message = "Each spf helper IP entry must be non-empty."
  }

  validation {
    condition     = var.spf == null ? true : try(var.spf.redirect == null || length(trimspace(var.spf.redirect)) > 0, true)
    error_message = "The spf helper redirect must be null or a non-empty domain name."
  }

  validation {
    condition     = var.spf == null ? true : try(var.spf.ttl == null || var.spf.ttl == 1 || var.spf.ttl >= 60 && var.spf.ttl <= 86400, true)
    error_message = "The spf helper ttl must be between 60 and 86400, or 1 for automatic."
  }
}

variable "dmarc" {
  type = object({
    policy           = string
    subdomain_policy = optional(string)
    percent          = optional(number, 100)
    spf_mode         = optional(string, "relaxed")
    dkim_mode        = optional(string, "relaxed")
    rua              = optional(list(string), [])
    ruf              = optional(list(string), [])
    fo               = optional(string)
    ttl              = optional(number)
    comment          = optional(string)
  })
  default     = null
  description = <<-EOT
    Helper for the DMARC TXT record published at `_dmarc`.

    Example:

    ```hcl
    dmarc = {
      policy    = "quarantine"
      rua       = ["mailto:dmarc@example.com"]
      spf_mode  = "relaxed"
      dkim_mode = "relaxed"
    }
    ```
  EOT

  validation {
    condition     = var.dmarc == null ? true : contains(["none", "quarantine", "reject"], var.dmarc.policy)
    error_message = "The dmarc helper policy must be one of: none, quarantine, reject."
  }

  validation {
    condition     = var.dmarc == null ? true : try(var.dmarc.subdomain_policy == null || contains(["none", "quarantine", "reject"], var.dmarc.subdomain_policy), true)
    error_message = "The dmarc helper subdomain_policy must be null or one of: none, quarantine, reject."
  }

  validation {
    condition     = var.dmarc == null ? true : contains(["relaxed", "strict"], var.dmarc.spf_mode) && contains(["relaxed", "strict"], var.dmarc.dkim_mode)
    error_message = "The dmarc helper spf_mode and dkim_mode must be either relaxed or strict."
  }

  validation {
    condition     = var.dmarc == null ? true : var.dmarc.percent >= 0 && var.dmarc.percent <= 100
    error_message = "The dmarc helper percent must be between 0 and 100."
  }

  validation {
    condition = var.dmarc == null ? true : alltrue([
      for address in concat(try(var.dmarc.rua, []), try(var.dmarc.ruf, [])) : length(trimspace(address)) > 0
    ])
    error_message = "Each dmarc helper rua and ruf entry must be non-empty."
  }

  validation {
    condition     = var.dmarc == null ? true : try(var.dmarc.fo == null || length(trimspace(var.dmarc.fo)) > 0, true)
    error_message = "The dmarc helper fo value must be null or non-empty."
  }

  validation {
    condition     = var.dmarc == null ? true : try(var.dmarc.ttl == null || var.dmarc.ttl == 1 || var.dmarc.ttl >= 60 && var.dmarc.ttl <= 86400, true)
    error_message = "The dmarc helper ttl must be between 60 and 86400, or 1 for automatic."
  }
}

variable "tlsrpt" {
  type = object({
    rua     = list(string)
    ttl     = optional(number)
    comment = optional(string)
  })
  default     = null
  description = <<-EOT
    Helper for the SMTP TLS Reporting TXT record published at `_smtp._tls`.

    Example:

    ```hcl
    tlsrpt = {
      rua = ["mailto:tlsrpt@example.com"]
    }
    ```
  EOT

  validation {
    condition     = var.tlsrpt == null ? true : length(var.tlsrpt.rua) > 0
    error_message = "The tlsrpt helper must define at least one rua destination."
  }

  validation {
    condition = var.tlsrpt == null ? true : alltrue([
      for address in var.tlsrpt.rua : length(trimspace(address)) > 0
    ])
    error_message = "Each tlsrpt helper rua entry must be non-empty."
  }

  validation {
    condition     = var.tlsrpt == null ? true : try(var.tlsrpt.ttl == null || var.tlsrpt.ttl == 1 || var.tlsrpt.ttl >= 60 && var.tlsrpt.ttl <= 86400, true)
    error_message = "The tlsrpt helper ttl must be between 60 and 86400, or 1 for automatic."
  }
}

variable "dkim" {
  type = map(object({
    type       = string
    public_key = optional(string)
    key_type   = optional(string, "rsa")
    target     = optional(string)
    ttl        = optional(number)
    comment    = optional(string)
  }))
  default     = null
  description = <<-EOT
    Helper for DKIM DNS records.

    The map key is the DKIM selector. Supported record types are `TXT` and `CNAME`.

    Example:

    ```hcl
    dkim = {
      selector1 = {
        type       = "TXT"
        public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A..."
      }

      google = {
        type   = "CNAME"
        target = "google._domainkey.provider.net"
      }
    }
    ```
  EOT

  validation {
    condition = var.dkim == null ? true : alltrue([
      for selector, cfg in var.dkim :
      length(trimspace(selector)) > 0 && contains(["TXT", "CNAME"], upper(cfg.type))
    ])
    error_message = "Each dkim helper entry must define a non-empty selector and a type of TXT or CNAME."
  }

  validation {
    condition = var.dkim == null ? true : alltrue([
      for selector, cfg in var.dkim :
      upper(cfg.type) == "TXT"
      ? try(length(trimspace(cfg.public_key)) > 0, false) && try(cfg.target == null, true)
      : try(length(trimspace(cfg.target)) > 0, false) && try(cfg.public_key == null, true)
    ])
    error_message = "For dkim helper entries: TXT requires public_key and must not define target; CNAME requires target and must not define public_key."
  }

  validation {
    condition = var.dkim == null ? true : alltrue([
      for selector, cfg in var.dkim :
      try(cfg.ttl == null || cfg.ttl == 1 || cfg.ttl >= 60 && cfg.ttl <= 86400, true)
    ])
    error_message = "Each dkim helper ttl must be between 60 and 86400, or 1 for automatic."
  }

  validation {
    condition = var.dkim == null ? true : alltrue([
      for selector, cfg in var.dkim :
      upper(cfg.type) == "TXT" ? length(trimspace(try(cfg.key_type, "rsa"))) > 0 : true
    ])
    error_message = "Each TXT dkim helper entry must define a non-empty key_type when provided."
  }
}

variable "comment" {
  type        = string
  default     = ""
  description = "Optional global comment added to all DNS records that do not define their own comment."
}

variable "rulesets" {
  type = list(object({
    key           = string
    name          = string
    description   = optional(string)
    kind          = string
    phase         = string
    account_level = optional(bool)

    rules = optional(list(object({
      ref         = string
      action      = string
      expression  = optional(string)
      description = optional(string)
      enabled     = optional(bool)

      action_parameters = optional(object({
        cache                      = optional(bool)
        origin_error_page_passthru = optional(bool)
        respect_strong_etags       = optional(bool)
        version                    = optional(string)

        response = optional(object({
          status_code  = optional(number)
          content      = optional(string)
          content_type = optional(string)
        }))

        from_value = optional(object({
          status_code           = optional(number)
          preserve_query_string = optional(bool)

          target_url = optional(object({
            value      = optional(string)
            expression = optional(string)
          }))
        }))

        edge_ttl = optional(object({
          mode    = string
          default = optional(number)

          status_code_ttl = optional(list(object({
            status_code = optional(number)
            status_code_range = optional(object({
              from = number
              to   = number
            }))
            value = number
          })))
        }))

        browser_ttl = optional(object({
          mode    = string
          default = optional(number)
        }))

        serve_stale = optional(object({
          disable_stale_while_updating = optional(bool)
        }))

        cache_key = optional(object({
          ignore_query_strings_order = optional(bool)
          cache_by_device_type       = optional(bool)
        }))

        uri = optional(object({
          path = optional(object({
            value      = optional(string)
            expression = optional(string)
          }))
        }))

        headers = optional(map(object({
          operation  = string
          value      = optional(string)
          expression = optional(string)
        })))

        host_header = optional(string)
      }))

      logging = optional(object({
        enabled = bool
      }))

      ratelimit = optional(object({
        characteristics            = list(string)
        period                     = number
        requests_per_period        = number
        mitigation_timeout         = number
        requests_to_origin         = optional(bool)
        score_per_period           = optional(number)
        score_response_header_name = optional(string)
        counting_expression        = optional(string)
      }))

      exposed_credential_check = optional(object({
        username_expression = string
        password_expression = string
      }))
    })))
  }))
  default     = []
  description = <<-EOT
    Cloudflare Ruleset Engine wrapper.

    Each item creates one `cloudflare_ruleset` resource.
    Supported scopes:
      * zone-level rulesets when `account_level = false` or omitted
      * account-level rulesets when `account_level = true`

    This wrapper accepts a simplified input shape and internally converts it
    to the Cloudflare provider v5 resource schema.

    Transform Rules (URL rewrite, header modifications, redirects) use this
    wrapper with `kind = "zone"` and one of these phases:
      * `http_request_transform`           — URL rewrites (action `rewrite`, `uri.path`)
      * `http_request_early_transform` /
        `http_request_late_transform`      — request header modification
      * `http_response_headers_transform`  — response header modification
                                              (action `rewrite`, `headers`)
    Example (CORS for a path prefix):
      rulesets = [{
        key   = "cors-assets-img"
        name  = "CORS on /assets/img/"
        kind  = "zone"
        phase = "http_response_headers_transform"
        rules = [{
          ref         = "cors-assets-img"
          expression  = "starts_with(http.request.uri.path, \"/assets/img/\")"
          action      = "rewrite"
          action_parameters = {
            headers = {
              "Access-Control-Allow-Origin" = {
                operation = "set"
                value     = "*"
              }
            }
          }
        }]
      }]

    `action_parameters.headers` operation is a free-form string passed
    through to the provider (documented values: "add", "set", "remove";
    the API may accept others such as "prepend"/"append" for specific
    headers, e.g. `set-cookie`). Removing a header requires no
    `value`/`expression`; every other operation requires one of them.

    Limits (see https://developers.cloudflare.com/rules/transform/):
      * Free plan: max 10 active Transform Rules per zone, shared across all
        transform phases; regex (the `matches` operator) requires Business
        plan or higher.
      * Header names starting with `cf-`/`x-cf-` cannot be modified; to
        append `set-cookie` use operation `add`, not `set`.
  EOT

  validation {
    condition = alltrue([
      for rs in var.rulesets :
      length(trimspace(rs.key)) > 0 &&
      length(trimspace(rs.name)) > 0 &&
      length(trimspace(rs.kind)) > 0 &&
      length(trimspace(rs.phase)) > 0
    ])
    error_message = "Each ruleset must define non-empty key, name, kind and phase."
  }

  validation {
    condition = length(var.rulesets) == length(distinct([
      for rs in var.rulesets : rs.key
    ]))
    error_message = "Each ruleset key must be unique."
  }

  validation {
    condition = alltrue(flatten([
      for rs in var.rulesets : [
        for rule in try(rs.rules, []) :
        length(trimspace(rule.ref)) > 0 &&
        length(trimspace(rule.action)) > 0
      ]
    ]))
    error_message = "Each rule must define non-empty ref and action."
  }

  validation {
    condition = alltrue(flatten([
      for rs in var.rulesets : [
        for rule in try(rs.rules, []) : [
          for name, header in coalesce(try(rule.action_parameters.headers, null), {}) :
          header.operation == "remove" ||
          header.value != null ||
          header.expression != null
        ]
      ]
    ]))
    error_message = "action_parameters.headers: every header operation other than \"remove\" requires `value` or `expression`."
  }
}

variable "transform_rules" {
  type = object({
    rules = optional(list(object({
      key         = string
      name        = optional(string)
      description = optional(string)
      type        = string # response_headers | request_headers | url_rewrite | redirect

      match = optional(object({
        path        = optional(string)
        path_prefix = optional(string)
        path_suffix = optional(string)
        path_regex  = optional(string)
        host        = optional(string)
        method      = optional(string)
      }))

      response_headers = optional(map(object({
        operation  = string
        value      = optional(string)
        expression = optional(string)
      })))

      request_headers = optional(map(object({
        operation  = string
        value      = optional(string)
        expression = optional(string)
      })))

      url_rewrite = optional(object({
        path = string
      }))

      redirect = optional(object({
        url         = string
        status_code = optional(number)
      }))
    })), [])

    # Named, ready-made recipes that expand into the same pipeline as
    # `rules` above — no Rules-language or `match`/`type` bookkeeping
    # needed. `cors` and `browser_cache_static` are lists because you may
    # want more than one (different paths, different settings); `hsts`
    # and `security_headers` are single blocks because they are global,
    # zone-wide headers — a zone has exactly one HSTS policy, not several.
    presets = optional(object({
      cors = optional(list(object({
        key           = string
        paths         = list(string)
        allow_origin  = string
        allow_methods = optional(list(string))
        allow_headers = optional(list(string))
      })))

      hsts = optional(object({
        max_age            = number
        include_subdomains = optional(bool)
        preload            = optional(bool)
      }))

      security_headers = optional(object({
        nosniff                 = optional(bool)
        x_frame_options         = optional(string)
        referrer_policy         = optional(string)
        content_security_policy = optional(string)
      }))

      browser_cache_static = optional(list(object({
        key         = string
        path_prefix = string
        max_age     = number
        immutable   = optional(bool)
      })))
    }))
  })
  default     = {}
  description = <<-EOT
    Simplified Transform Rules. `rules` items and expanded `presets` items
    both become `cloudflare_ruleset` entries (kind `zone`) grouped by
    phase — no Rules-language writing needed. For full control use the
    `rulesets` input instead.

    `rules[*].type` values and phases:
      * `response_headers` — phase `http_response_headers_transform` (`response_headers` payload)
      * `request_headers`  — phase `http_request_late_transform` (`request_headers` payload)
      * `url_rewrite`      — phase `http_request_transform` (`url_rewrite.path` payload)
      * `redirect`         — phase `http_request_dynamic_redirect` (`redirect.url` + optional `status_code`)

    `rules[*].match` fields (combined with AND; omit `match` for a global rule):
      * `path`        — exact path match
      * `path_prefix` — starts_with
      * `path_suffix` — ends_with
      * `path_regex`  — regex (RE2). Requires Business plan or higher;
        regex is NOT available for Transform Rules on Free/Pro plans.
      * `host`        — exact host match
      * `method`      — exact HTTP method match

    `response_headers`/`request_headers` operation is a free-form string
    passed through to the provider (documented values: "add", "set",
    "remove"; the API may accept others such as "prepend"/"append" for
    specific headers, e.g. `set-cookie`). Removing a header requires no
    `value`/`expression`; every other operation requires one of them.

    `presets`:
      * `cors`                  — one or more CORS response-header blocks, one ruleset rule per path
      * `hsts`                  — Strict-Transport-Security (global)
      * `security_headers`      — common security response headers (global):
          `nosniff` (default true), `x_frame_options`, `referrer_policy`, `content_security_policy`
      * `browser_cache_static`  — one or more browser-facing Cache-Control
        blocks per path prefix. WARNING: sets the response header seen by
        browsers only — it does NOT change Cloudflare edge caching; use
        the `rulesets` input with cache rules for that
        (https://developers.cloudflare.com/rules/transform/response-header-modification/).

    Limits (see https://developers.cloudflare.com/rules/transform/):
      * Free plan: max 10 active Transform Rules per zone, shared across all
        transform phases; regex (the `matches` operator) requires Business
        plan or higher.
      * Header names starting with `cf-`/`x-cf-` cannot be modified; to
        append `set-cookie` use operation `add`, not `set`.

    Example:
      transform_rules = {
        rules = [
          {
            key   = "cors-assets"
            type  = "response_headers"
            match = { path_prefix = "/assets/" }
            response_headers = {
              "Access-Control-Allow-Origin" = { operation = "set", value = "*" }
            }
          }
        ]
        presets = {
          hsts = {
            max_age            = 31536000
            include_subdomains = true
          }
        }
      }
  EOT

  validation {
    condition = alltrue([
      for tr in coalesce(var.transform_rules.rules, []) :
      contains(["response_headers", "request_headers", "url_rewrite", "redirect"], tr.type)
    ])
    error_message = "transform_rules.rules: type must be one of response_headers, request_headers, url_rewrite, redirect."
  }

  validation {
    condition = alltrue([
      for tr in coalesce(var.transform_rules.rules, []) :
      (
        (tr.type == "response_headers" && tr.response_headers != null && tr.request_headers == null && tr.url_rewrite == null && tr.redirect == null) ||
        (tr.type == "request_headers" && tr.request_headers != null && tr.response_headers == null && tr.url_rewrite == null && tr.redirect == null) ||
        (tr.type == "url_rewrite" && tr.url_rewrite != null && tr.response_headers == null && tr.request_headers == null && tr.redirect == null) ||
        (tr.type == "redirect" && tr.redirect != null && tr.response_headers == null && tr.request_headers == null && tr.url_rewrite == null)
      )
    ])
    error_message = "transform_rules.rules: each item must define exactly the payload matching its type."
  }

  validation {
    condition = length(coalesce(var.transform_rules.rules, [])) == length(distinct([
      for tr in coalesce(var.transform_rules.rules, []) : tr.key
    ]))
    error_message = "transform_rules.rules: keys must be unique."
  }

  validation {
    condition = alltrue([
      for tr in coalesce(var.transform_rules.rules, []) :
      try(tr.match, null) == null ||
      (try(tr.match.path, null) == null || (try(tr.match.path_prefix, null) == null && try(tr.match.path_suffix, null) == null && try(tr.match.path_regex, null) == null))
    ])
    error_message = "transform_rules.rules: match.path is exclusive with path_prefix/path_suffix/path_regex."
  }

  validation {
    condition = alltrue(flatten([
      for tr in coalesce(var.transform_rules.rules, []) : concat(
        [for name, h in coalesce(try(tr.response_headers, null), {}) : h.operation == "remove" || h.value != null || h.expression != null],
        [for name, h in coalesce(try(tr.request_headers, null), {}) : h.operation == "remove" || h.value != null || h.expression != null]
      )
    ]))
    error_message = "transform_rules.rules: every header operation other than \"remove\" requires `value` or `expression`."
  }

  validation {
    condition = alltrue([
      for c in coalesce(try(var.transform_rules.presets.cors, null), []) : length(c.paths) > 0
    ])
    error_message = "transform_rules.presets.cors: paths must not be empty."
  }

  validation {
    condition = length(coalesce(try(var.transform_rules.presets.cors, null), [])) == length(distinct([
      for c in coalesce(try(var.transform_rules.presets.cors, null), []) : c.key
    ]))
    error_message = "transform_rules.presets.cors: keys must be unique."
  }

  validation {
    condition     = try(var.transform_rules.presets.hsts, null) == null ? true : var.transform_rules.presets.hsts.max_age > 0
    error_message = "transform_rules.presets.hsts: max_age must be > 0."
  }

  validation {
    condition = alltrue([
      for b in coalesce(try(var.transform_rules.presets.browser_cache_static, null), []) : b.max_age > 0
    ])
    error_message = "transform_rules.presets.browser_cache_static: max_age must be > 0."
  }

  validation {
    condition = length(coalesce(try(var.transform_rules.presets.browser_cache_static, null), [])) == length(distinct([
      for b in coalesce(try(var.transform_rules.presets.browser_cache_static, null), []) : b.key
    ]))
    error_message = "transform_rules.presets.browser_cache_static: keys must be unique."
  }
}

variable "universal_ssl_setting" {
  type = object({
    enabled = optional(bool)
  })
  default     = null
  description = <<-EOT
    Universal SSL setting for the zone, managed with `cloudflare_universal_ssl_setting`.

    Example:

    ```hcl
    universal_ssl_setting = {
      enabled = true
    }
    ```
  EOT
}

variable "zone_cache_reserve" {
  type = object({
    value = optional(string)
  })
  default     = null
  description = <<-EOT
    Cache Reserve setting for the zone, managed with `cloudflare_zone_cache_reserve`.

    Example:

    ```hcl
    zone_cache_reserve = {
      value = "on"
    }
    ```
  EOT

  validation {
    condition     = var.zone_cache_reserve == null ? true : contains(["on", "off"], try(var.zone_cache_reserve.value, "on"))
    error_message = "The zone_cache_reserve value must be either on or off."
  }
}

variable "tiered_cache" {
  type = object({
    value = optional(string)
  })
  default     = null
  description = <<-EOT
    Smart Tiered Cache setting for the zone, managed with `cloudflare_tiered_cache`.

    Example:

    ```hcl
    tiered_cache = {
      value = "on"
    }
    ```
  EOT

  validation {
    condition     = var.tiered_cache == null ? true : contains(["on", "off"], try(var.tiered_cache.value, "on"))
    error_message = "The tiered_cache value must be either on or off."
  }
}

variable "regional_tiered_cache" {
  type = object({
    value = optional(string)
  })
  default     = null
  description = <<-EOT
    Regional Tiered Cache setting for the zone, managed with `cloudflare_regional_tiered_cache`.

    Example:

    ```hcl
    regional_tiered_cache = {
      value = "on"
    }
    ```
  EOT

  validation {
    condition     = var.regional_tiered_cache == null ? true : contains(["on", "off"], try(var.regional_tiered_cache.value, "on"))
    error_message = "The regional_tiered_cache value must be either on or off."
  }
}

variable "zone_cache_variants" {
  type = object({
    value = optional(object({
      avif = optional(list(string))
      bmp  = optional(list(string))
      gif  = optional(list(string))
      jp2  = optional(list(string))
      jpeg = optional(list(string))
      jpg  = optional(list(string))
      jpg2 = optional(list(string))
      png  = optional(list(string))
      tif  = optional(list(string))
      tiff = optional(list(string))
      webp = optional(list(string))
    }))
  })
  default     = null
  description = <<-EOT
    Cache Variants setting for the zone, managed with `cloudflare_zone_cache_variants`.

    Each key lists the alternate MIME types Cloudflare may serve instead of the
    source image format, when the client's Accept header allows it.

    Example:

    ```hcl
    zone_cache_variants = {
      value = {
        webp = ["image/jpeg", "image/avif"]
      }
    }
    ```
  EOT
}

variable "zone_dns_settings" {
  type = object({
    flatten_all_cnames  = optional(bool)
    foundation_dns      = optional(bool)
    multi_provider      = optional(bool)
    secondary_overrides = optional(bool)
    ns_ttl              = optional(number)
    zone_mode           = optional(string)

    internal_dns = optional(object({
      reference_zone_id = string
    }))

    nameservers = optional(object({
      type              = string
      nameserver_set_id = optional(string)
      ns_set            = optional(number)
    }))

    soa = optional(object({
      expire  = optional(number)
      min_ttl = optional(number)
      mname   = optional(string)
      refresh = optional(number)
      retry   = optional(number)
      rname   = optional(string)
      ttl     = optional(number)
    }))
  })
  default     = null
  description = <<-EOT
    DNS settings for the zone, managed with `cloudflare_zone_dns_settings`.

    Example:

    ```hcl
    zone_dns_settings = {
      flatten_all_cnames = true
      zone_mode          = "dns_only"
    }
    ```
  EOT

  validation {
    condition     = var.zone_dns_settings == null ? true : try(contains(["standard", "cdn_only", "dns_only"], var.zone_dns_settings.zone_mode), true)
    error_message = "The zone_dns_settings zone_mode must be one of: standard, cdn_only, dns_only."
  }
}

variable "email_routing_settings" {
  type = object({
    support_subaddress = optional(bool)
  })
  default     = null
  description = <<-EOT
    Email Routing settings for the zone, managed with `cloudflare_email_routing_settings`.

    Example:

    ```hcl
    email_routing_settings = {
      support_subaddress = true
    }
    ```
  EOT
}

variable "nel_setting" {
  type = object({
    value = object({
      enabled = bool
    })
  })
  default     = null
  description = <<-EOT
    Network Error Logging setting for the zone, managed with `cloudflare_nel_setting`.

    Example:

    ```hcl
    nel_setting = {
      value = {
        enabled = true
      }
    }
    ```
  EOT
}

variable "authenticated_origin_pulls_settings" {
  type = object({
    enabled = optional(bool)
  })
  default     = null
  description = <<-EOT
    Zone-level Authenticated Origin Pulls setting, managed with `cloudflare_authenticated_origin_pulls_settings`.

    Example:

    ```hcl
    authenticated_origin_pulls_settings = {
      enabled = true
    }
    ```
  EOT
}

variable "zone_hold" {
  type = object({
    include_subdomains = optional(bool, false)
  })
  default     = null
  description = <<-EOT
    Zone Hold for the zone, managed with `cloudflare_zone_hold`.

    Blocks the creation and activation of any zone using this zone's hostname.
    Declaring this object enables the hold; omitting it (the default) leaves no
    hold in place. Scheduling a temporary release via `hold_after` is not
    supported by this helper.

    Example:

    ```hcl
    zone_hold = {
      include_subdomains = true
    }
    ```
  EOT
}

variable "zone_lockdowns" {
  type = list(object({
    key         = string
    urls        = list(string)
    description = optional(string)
    paused      = optional(bool)
    priority    = optional(number)

    configurations = list(object({
      target = string
      value  = string
    }))
  }))
  default     = []
  description = <<-EOT
    Zone Lockdown rules, managed with `cloudflare_zone_lockdown`.

    Restricts access to the listed `urls` to the IPs or IP ranges declared in
    `configurations`.

    Example:

    ```hcl
    zone_lockdowns = [
      {
        key  = "admin-panel"
        urls = ["admin.example.com/*"]

        configurations = [
          {
            target = "ip"
            value  = "198.51.100.4"
          }
        ]
      }
    ]
    ```
  EOT

  validation {
    condition = length(var.zone_lockdowns) == length(distinct([
      for l in var.zone_lockdowns : l.key
    ]))
    error_message = "Each zone_lockdowns key must be unique."
  }

  validation {
    condition = alltrue([
      for l in var.zone_lockdowns : length(l.urls) > 0 && length(l.configurations) > 0
    ])
    error_message = "Each zone_lockdowns entry must define at least one url and one configuration."
  }

  validation {
    condition = alltrue(flatten([
      for l in var.zone_lockdowns : [
        for c in l.configurations : contains(["ip", "ip_range"], c.target)
      ]
    ]))
    error_message = "Each zone_lockdowns configuration target must be either ip or ip_range."
  }
}

variable "hostname_tls_settings" {
  type = object({
    ciphers = optional(list(object({
      hostname = string
      value    = list(string)
    })), [])

    min_tls_version = optional(list(object({
      hostname = string
      value    = string
    })), [])

    http2 = optional(list(object({
      hostname = string
      value    = string
    })), [])
  })
  default     = {}
  description = <<-EOT
    Per-hostname TLS settings, managed with `cloudflare_hostname_tls_setting`.

    Split into one bucket per `setting_id` (`ciphers`, `min_tls_version`,
    `http2`) because each has a different `value` shape (a list of cipher
    suite strings vs. a single string) and Terraform cannot type a single
    list whose elements legitimately differ in shape.

    Example:

    ```hcl
    hostname_tls_settings = {
      min_tls_version = [
        { hostname = "app.example.com", value = "1.2" }
      ]
      ciphers = [
        { hostname = "app.example.com", value = ["ECDHE-RSA-AES128-GCM-SHA256"] }
      ]
    }
    ```
  EOT

  validation {
    condition = length(var.hostname_tls_settings.ciphers) == length(distinct([
      for s in var.hostname_tls_settings.ciphers : s.hostname
    ]))
    error_message = "Each hostname_tls_settings.ciphers hostname must be unique."
  }

  validation {
    condition = length(var.hostname_tls_settings.min_tls_version) == length(distinct([
      for s in var.hostname_tls_settings.min_tls_version : s.hostname
    ]))
    error_message = "Each hostname_tls_settings.min_tls_version hostname must be unique."
  }

  validation {
    condition = length(var.hostname_tls_settings.http2) == length(distinct([
      for s in var.hostname_tls_settings.http2 : s.hostname
    ]))
    error_message = "Each hostname_tls_settings.http2 hostname must be unique."
  }

  validation {
    condition = alltrue([
      for s in var.hostname_tls_settings.min_tls_version : contains(["1.0", "1.1", "1.2", "1.3"], s.value)
    ])
    error_message = "Each hostname_tls_settings.min_tls_version value must be one of: 1.0, 1.1, 1.2, 1.3."
  }

  validation {
    condition = alltrue([
      for s in var.hostname_tls_settings.http2 : contains(["on", "off"], s.value)
    ])
    error_message = "Each hostname_tls_settings.http2 value must be either on or off."
  }
}

variable "page_rules" {
  type = list(object({
    key      = string
    target   = string
    priority = optional(number)
    status   = optional(string)

    actions = object({
      always_use_https         = optional(bool)
      automatic_https_rewrites = optional(string)
      browser_cache_ttl        = optional(number)
      browser_check            = optional(string)
      bypass_cache_on_cookie   = optional(string)
      cache_by_device_type     = optional(string)
      cache_deception_armor    = optional(string)
      cache_level              = optional(string)
      cache_on_cookie          = optional(string)
      cache_ttl_by_status      = optional(map(string))
      edge_cache_ttl           = optional(number)
      email_obfuscation        = optional(string)
      explicit_cache_control   = optional(string)

      forwarding_url = optional(object({
        status_code = number
        url         = string
      }))

      host_header_override        = optional(string)
      ip_geolocation              = optional(string)
      mirage                      = optional(string)
      opportunistic_encryption    = optional(string)
      origin_error_page_pass_thru = optional(string)
      polish                      = optional(string)
      resolve_override            = optional(string)
      respect_strong_etag         = optional(string)
      response_buffering          = optional(string)
      rocket_loader               = optional(string)
      security_level              = optional(string)
      sort_query_string_for_cache = optional(string)
      ssl                         = optional(string)
      true_client_ip_header       = optional(string)
      waf                         = optional(string)
    })
  }))
  default     = []
  description = <<-EOT
    Page Rules, managed with `cloudflare_page_rule`.

    `actions` enumerates every Page Rule action as an optional field so each
    entry constructs against one static type regardless of which actions it
    sets (Terraform cannot type a list whose elements legitimately combine
    different action keys any other way). The `cache_key_fields` action is
    not covered by this helper — use `rulesets` (Cache Rules) for that, which
    is also Cloudflare's recommended replacement for Page Rules generally.

    Example:

    ```hcl
    page_rules = [
      {
        key    = "force-https"
        target = "example.com/*"

        actions = {
          always_use_https = true
        }
      }
    ]
    ```
  EOT

  validation {
    condition = length(var.page_rules) == length(distinct([
      for p in var.page_rules : p.key
    ]))
    error_message = "Each page_rules key must be unique."
  }

  validation {
    condition = alltrue([
      for p in var.page_rules : length(trimspace(p.target)) > 0
    ])
    error_message = "Each page_rules entry must define a non-empty target."
  }
}

variable "worker_routes" {
  type = list(object({
    pattern = string
    script  = string
  }))
  default     = []
  description = <<-EOT
    Cloudflare Workers routes bound to this zone, managed with
    `cloudflare_workers_route`.

    Each entry binds a URL pattern within this zone to an existing Worker
    script name.

    Example:

    ```hcl
    worker_routes = [
      {
        pattern = "api.example.com/*"
        script  = "my-worker"
      }
    ]
    ```
  EOT

  validation {
    condition = length(var.worker_routes) == length(distinct([
      for r in var.worker_routes : r.pattern
    ]))
    error_message = "Each worker_routes pattern must be unique within a zone."
  }

  validation {
    condition = alltrue([
      for r in var.worker_routes : length(trimspace(r.pattern)) > 0 && length(trimspace(r.script)) > 0
    ])
    error_message = "Each worker_routes entry must define a non-empty pattern and script."
  }
}

variable "worker_hostnames" {
  type = list(object({
    hostname = string
    script   = string
  }))
  default     = []
  description = <<-EOT
    Hostnames bound exclusively to a Worker script via Cloudflare Custom
    Domains, managed with `cloudflare_workers_custom_domain`.

    Unlike `worker_routes`, a custom domain is host-exclusive (no path
    pattern) and Cloudflare provisions DNS and TLS for it automatically -
    no separate DNS record is needed in this zone's records.

    Example:

    ```hcl
    worker_hostnames = [
      {
        hostname = "api.example.com"
        script   = "my-worker"
      }
    ]
    ```
  EOT

  validation {
    condition = length(var.worker_hostnames) == length(distinct([
      for wh in var.worker_hostnames : wh.hostname
    ]))
    error_message = "Each worker_hostnames hostname must be unique."
  }

  validation {
    condition = alltrue([
      for wh in var.worker_hostnames : length(trimspace(wh.hostname)) > 0 && length(trimspace(wh.script)) > 0
    ])
    error_message = "Each worker_hostnames entry must define a non-empty hostname and script."
  }
}

variable "managed_transforms" {
  type = object({
    request  = optional(list(string))
    response = optional(list(string))
  })
  default     = null
  description = <<-EOT
    Managed Transforms — prebuilt HTTP header adjustments, managed with
    `cloudflare_managed_transforms`.

    List the transform IDs to enable, per direction. Every listed ID is
    applied with `enabled = true`; removing an ID from the list stops
    managing that transform.

    Valid IDs (see "Available Managed Transforms" in the docs):
      request  e.g. "add_visitor_location_headers"
      response e.g. "remove_x-powered-by_header"

    Notes:
      * Managed Transforms run BEFORE regular transform rules.
      * Some transforms are plan-gated (e.g. Exposed-Credential-Check
        response headers require Pro/Enterprise) — check the availability
        column of the reference table.

    Example:
      managed_transforms = {
        response = ["remove_x-powered-by_header"]
      }
  EOT

  validation {
    condition = var.managed_transforms == null || alltrue([
      length(coalesce(try(var.managed_transforms.request, null), [])) == length(distinct(coalesce(try(var.managed_transforms.request, null), []))),
      length(coalesce(try(var.managed_transforms.response, null), [])) == length(distinct(coalesce(try(var.managed_transforms.response, null), []))),
      alltrue(flatten([
        [for id in coalesce(try(var.managed_transforms.request, null), []) : length(trimspace(id)) > 0],
        [for id in coalesce(try(var.managed_transforms.response, null), []) : length(trimspace(id)) > 0]
      ]))
    ])
    error_message = "managed_transforms: IDs must be non-empty and unique within each direction."
  }
}

variable "url_normalization" {
  type = object({
    scope = string
    type  = string
  })
  default     = null
  description = <<-EOT
    URL normalization settings, managed with
    `cloudflare_url_normalization_settings`. Available on all plans:
    https://developers.cloudflare.com/rules/normalization/

    `scope`: "incoming" | "both" | "none"
    `type`:  "cloudflare" | "rfc3986"

    Example:
      url_normalization = {
        scope = "incoming"
        type  = "cloudflare"
      }
  EOT

  validation {
    condition     = var.url_normalization == null ? true : contains(["incoming", "both", "none"], var.url_normalization.scope)
    error_message = "url_normalization.scope must be one of: incoming, both, none."
  }

  validation {
    condition     = var.url_normalization == null ? true : contains(["cloudflare", "rfc3986"], var.url_normalization.type)
    error_message = "url_normalization.type must be one of: cloudflare, rfc3986."
  }
}

variable "lists" {
  type = list(object({
    key         = string
    kind        = string # "ip" (IP list). Hostname/ASN/redirect lists are not exposed here.
    name        = string
    description = optional(string)
    items = optional(list(object({
      ip      = optional(string)
      comment = optional(string)
    })))
  }))
  default     = []
  description = <<-EOT
    Custom lists (`cloudflare_list`) — groups of IPs referenceable in rule
    expressions, e.g. `ip.src in cf.list["my-list"]`.
    Free plan limits: 1 custom list, 10,000 total items, IP lists only
    (https://developers.cloudflare.com/waf/tools/lists/).

    Only `kind = "ip"` is supported by this input. Hostname/ASN/redirect
    lists exist in the Cloudflare API but are not exposed here.

    Example:
      lists = [
        {
          key  = "office"
          kind = "ip"
          name = "office"
          items = [
            { ip = "203.0.113.10", comment = "office" }
          ]
        }
      ]
  EOT

  validation {
    condition     = length(var.lists) == length(distinct([for l in var.lists : l.key]))
    error_message = "lists: key must be unique."
  }

  validation {
    condition     = alltrue([for l in var.lists : l.kind == "ip"])
    error_message = "lists: only kind \"ip\" (IP lists) is supported by this input."
  }

  validation {
    condition = alltrue(flatten([
      for l in var.lists : [for item in coalesce(try(l.items, null), []) : item.ip != null]
    ]))
    error_message = "lists: every item must define `ip`."
  }
}

variable "bot_management" {
  type = object({
    fight_mode                      = optional(bool)
    sbfm_definitely_automated       = optional(string) # allow | block | managed_challenge
    sbfm_likely_automated           = optional(string) # allow | block | managed_challenge
    sbfm_static_resource_protection = optional(bool)
    sbfm_verified_bots              = optional(string) # allow | block
    content_bots_protection         = optional(string) # block | disabled
    crawler_protection              = optional(string) # enabled | disabled
    ai_bots_protection              = optional(string) # block | disabled | only_on_ad_pages
    ai_training                     = optional(string) # disabled | disallow | block | only_on_ad_pages
    ai_user                         = optional(string) # disabled | block | only_on_ad_pages
    aisearch                        = optional(string) # disabled | block | only_on_ad_pages
    bm_cookie_enabled               = optional(bool)
    enable_js                       = optional(bool)
    is_robots_txt_managed           = optional(bool)
    optimize_wordpress              = optional(bool)
    cf_robots_variant               = optional(string) # off | policy_only
    jsd_api_results_enabled         = optional(bool)
    suppress_session_score          = optional(bool)
  })
  default     = null
  description = <<-EOT
    Zone Bot Management settings (`cloudflare_bot_management`).
    Base "Bots" is available on all plans. The `sbfm_*` fields are Super Bot
    Fight Mode and require Pro plan or higher; full Bot Management is
    Enterprise. See https://developers.cloudflare.com/bots/.

    Example:
      bot_management = {
        content_bots_protection = "block"
      }
  EOT

  validation {
    condition = var.bot_management == null ? true : alltrue([
      try(var.bot_management.sbfm_definitely_automated, null) == null ? true : contains(["allow", "block", "managed_challenge"], var.bot_management.sbfm_definitely_automated),
      try(var.bot_management.sbfm_likely_automated, null) == null ? true : contains(["allow", "block", "managed_challenge"], var.bot_management.sbfm_likely_automated),
      try(var.bot_management.sbfm_verified_bots, null) == null ? true : contains(["allow", "block"], var.bot_management.sbfm_verified_bots),
      try(var.bot_management.content_bots_protection, null) == null ? true : contains(["block", "disabled"], var.bot_management.content_bots_protection),
      try(var.bot_management.crawler_protection, null) == null ? true : contains(["enabled", "disabled"], var.bot_management.crawler_protection),
      try(var.bot_management.ai_bots_protection, null) == null ? true : contains(["block", "disabled", "only_on_ad_pages"], var.bot_management.ai_bots_protection),
      try(var.bot_management.ai_training, null) == null ? true : contains(["disabled", "disallow", "block", "only_on_ad_pages"], var.bot_management.ai_training),
      try(var.bot_management.ai_user, null) == null ? true : contains(["disabled", "block", "only_on_ad_pages"], var.bot_management.ai_user),
      try(var.bot_management.aisearch, null) == null ? true : contains(["disabled", "block", "only_on_ad_pages"], var.bot_management.aisearch),
      try(var.bot_management.cf_robots_variant, null) == null ? true : contains(["off", "policy_only"], var.bot_management.cf_robots_variant),
    ])
    error_message = "bot_management: one or more fields have an unsupported value. See the provider docs for cloudflare_bot_management for the allowed values of each field."
  }
}

variable "ip_access_rules" {
  type = list(object({
    key    = string
    mode   = string # block | challenge | whitelist | js_challenge | managed_challenge
    target = string # ip | ip6 | ip_range | asn (country is Enterprise-only, not supported here)
    value  = string
    notes  = optional(string)
  }))
  default     = []
  description = <<-EOT
    IP Access Rules (`cloudflare_access_rule`), one rule per item.
    Available to all customers; country targeting is Enterprise-only and
    not exposed here.

    Example:
      ip_access_rules = [
        {
          key    = "block-attacker"
          mode   = "block"
          target = "ip"
          value  = "203.0.113.10"
          notes  = "attacker from incident 2026-10"
        }
      ]
  EOT

  validation {
    condition     = length(var.ip_access_rules) == length(distinct([for r in var.ip_access_rules : r.key]))
    error_message = "ip_access_rules: key must be unique."
  }

  validation {
    condition = alltrue([
      for r in var.ip_access_rules :
      contains(["block", "challenge", "whitelist", "js_challenge", "managed_challenge"], r.mode) &&
      contains(["ip", "ip6", "ip_range", "asn"], r.target)
    ])
    error_message = "ip_access_rules: mode must be one of block, challenge, whitelist, js_challenge, managed_challenge; target must be one of ip, ip6, ip_range, asn."
  }
}

variable "user_agent_blocking_rules" {
  type = list(object({
    key         = string
    mode        = string # block | challenge | whitelist | js_challenge | managed_challenge
    value       = string # exact user agent string to match
    description = optional(string)
    paused      = optional(bool)
  }))
  default     = []
  description = <<-EOT
    User Agent Blocking rules (`cloudflare_user_agent_blocking_rule`).
    Available on all plans. Each item is one resource matching a single
    exact user-agent string — the provider's `configuration.target` for
    this resource only accepts "ua", there is no multi-condition list.

    Example:
      user_agent_blocking_rules = [
        {
          key   = "block-old-bot"
          mode  = "block"
          value = "BadBot/1.0"
        }
      ]
  EOT

  validation {
    condition     = length(var.user_agent_blocking_rules) == length(distinct([for r in var.user_agent_blocking_rules : r.key]))
    error_message = "user_agent_blocking_rules: key must be unique."
  }

  validation {
    condition = alltrue([
      for r in var.user_agent_blocking_rules :
      contains(["block", "challenge", "whitelist", "js_challenge", "managed_challenge"], r.mode) &&
      length(trimspace(r.value)) > 0
    ])
    error_message = "user_agent_blocking_rules: mode must be one of block, challenge, whitelist, js_challenge, managed_challenge; value must be non-empty."
  }
}

variable "origin_ca_certificates" {
  type = map(object({
    csr                = string
    hostnames          = list(string)
    request_type       = string           # origin-rsa | origin-ecc | keyless-certificate
    requested_validity = optional(number) # 7 | 30 | 90 | 365 | 730 | 1095 | 5475 (days)
  }))
  default     = null
  description = <<-EOT
    Origin CA certificates (`cloudflare_origin_ca_certificate`), keyed by
    your own key. Available on all plans. This resource is account-scoped
    (not tied to this module's zone) — generate the CSR off-Terraform
    (e.g. `openssl req -new -newkey rsa:2048 -nodes`) and pass it here.

    `request_type` selects the certificate's signature algorithm:
    "origin-rsa", "origin-ecc", or "keyless-certificate" (for Keyless SSL).
    `requested_validity` (days) must be one of 7, 30, 90, 365, 730, 1095,
    5475 when set.

    Example:
      origin_ca_certificates = {
        origin = {
          csr          = file("certs/origin.csr")
          hostnames    = ["example.com", "*.example.com"]
          request_type = "origin-rsa"
        }
      }
  EOT

  validation {
    condition = var.origin_ca_certificates == null ? true : alltrue([
      for k, v in var.origin_ca_certificates :
      length(trimspace(v.csr)) > 0 &&
      length(v.hostnames) > 0 &&
      contains(["origin-rsa", "origin-ecc", "keyless-certificate"], v.request_type) &&
      (try(v.requested_validity, null) == null ? true : contains([7, 30, 90, 365, 730, 1095, 5475], v.requested_validity))
    ])
    error_message = "origin_ca_certificates: each entry needs a non-empty csr, at least one hostname, request_type in origin-rsa|origin-ecc|keyless-certificate, and (if set) requested_validity in 7|30|90|365|730|1095|5475."
  }
}

variable "aop_certificate" {
  type = object({
    certificate = string
    private_key = string
  })
  default     = null
  sensitive   = true
  description = <<-EOT
    Zone-level Authenticated Origin Pulls certificate
    (`cloudflare_authenticated_origin_pulls_certificate`). Enable the zone
    setting via the existing `authenticated_origin_pulls_settings` input.
  EOT
}

variable "aop_hostname_certificates" {
  type = map(object({
    certificate = string
    private_key = string
    hostname    = string
    enabled     = optional(bool, true)
  }))
  default     = null
  sensitive   = true
  description = <<-EOT
    Per-hostname Authenticated Origin Pulls certificates, keyed by your own
    key. Uploading a certificate alone does not activate per-hostname AOP —
    Cloudflare requires a separate association step, so each entry both
    uploads the certificate (`cloudflare_authenticated_origin_pulls_hostname_certificate`)
    and associates + enables it for `hostname`
    (`cloudflare_authenticated_origin_pulls`).

    Example:
      aop_hostname_certificates = {
        api = {
          certificate = file("certs/api.pem")
          private_key = file("certs/api.key")
          hostname    = "api.example.com"
        }
      }
  EOT
}
