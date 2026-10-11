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
