# terraform-cloudflare-zone
## About

Terraform module to provision a CloudFlare zone with DNS record managment


## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```text
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to deal in the Software
without restriction.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

Source: https://opensource.org/licenses/MIT
```
See [LICENSE](LICENSE) for full details.
## Authors

- Rafał Masiarek | [website](https://masiarek.pl) | [email](mailto:rafal@masiarek.pl) | [github](https://github.com/rafalmasiarek)


## Submodules

Submodules included to root module that can be called independent:

- [single-record](https://github.com/Infrastrukturait/terraform-cloudflare-zone/tree/main/modules/single-record) - Root module creates an object with a full zone and object with all records, this small sub-module is to facilitate the creation of a single record to an existing zone.


## Notes

* The `name` and the `data.name` argument values default to `@` (root). This is actually the default behavior, but only for the value of the `data.name` argument when you are not using the module.
* The `data` argument is fully supported. The `value` argument takes precedence over the `data` argument to avoid errors if two arguments are accidentally given at the same time, since only one of them can be given at the same time.
* The `ttl` argument value defaults to `1` (automatic). This is actually the default behavior.
* The `ttl` argument value is forced to `1` (automatic), regardless of explicitly set value, if you set the `proxied` argument value to `true`.
* The `proxied` argument value defaults to `false`. This is actually the default behavior. You must explicitly set this argument value to `true` for the records that you want to proxy through Cloudflare.
* The `proxied` argument value is forced to `false` for unsupported record types, regardless of explicitly set value.
* The `proxied` argument value is forced to `false` for wildcard records for non-enterprise plans, regardless of explicitly set value, because non-enterprise customers can create but not proxy wildcard records.
* To create only each record without create whole zone, you can just use simple submodule [single-record](https://github.com/Infrastrukturait/terraform-cloudflare-zone/tree/main/modules/single-record).


<!-- BEGIN_TF_DOCS -->
## Documentation


### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 5.18.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [cloudflare_authenticated_origin_pulls_settings.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/authenticated_origin_pulls_settings) | resource |
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_email_routing_settings.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_settings) | resource |
| [cloudflare_hostname_tls_setting.ciphers](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/hostname_tls_setting) | resource |
| [cloudflare_hostname_tls_setting.http2](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/hostname_tls_setting) | resource |
| [cloudflare_hostname_tls_setting.min_tls_version](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/hostname_tls_setting) | resource |
| [cloudflare_nel_setting.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/nel_setting) | resource |
| [cloudflare_page_rule.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/page_rule) | resource |
| [cloudflare_regional_tiered_cache.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/regional_tiered_cache) | resource |
| [cloudflare_ruleset.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/ruleset) | resource |
| [cloudflare_tiered_cache.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/tiered_cache) | resource |
| [cloudflare_universal_ssl_setting.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/universal_ssl_setting) | resource |
| [cloudflare_workers_route.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/workers_route) | resource |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) | resource |
| [cloudflare_zone_cache_reserve.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_cache_reserve) | resource |
| [cloudflare_zone_cache_variants.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_cache_variants) | resource |
| [cloudflare_zone_dns_settings.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_dns_settings) | resource |
| [cloudflare_zone_dnssec.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_dnssec) | resource |
| [cloudflare_zone_hold.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_hold) | resource |
| [cloudflare_zone_lockdown.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_lockdown) | resource |
| [cloudflare_zone_setting.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Account ID to manage the zone resource in. You can get more information on how to find `account_id` at [this page](https://developers.cloudflare.com/fundamentals/get-started/basic-tasks/find-account-and-zone-ids/). | `string` | n/a | yes |
| <a name="input_authenticated_origin_pulls_settings"></a> [authenticated\_origin\_pulls\_settings](#input\_authenticated\_origin\_pulls\_settings) | Zone-level Authenticated Origin Pulls setting, managed with `cloudflare_authenticated_origin_pulls_settings`.<br><br>Example:<pre>hcl<br>authenticated_origin_pulls_settings = {<br>  enabled = true<br>}</pre> | <pre>object({<br>    enabled = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Optional global comment added to all DNS records that do not define their own comment. | `string` | `""` | no |
| <a name="input_dkim"></a> [dkim](#input\_dkim) | Helper for DKIM DNS records.<br><br>The map key is the DKIM selector. Supported record types are `TXT` and `CNAME`.<br><br>Example:<pre>hcl<br>dkim = {<br>  selector1 = {<br>    type       = "TXT"<br>    public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A..."<br>  }<br><br>  google = {<br>    type   = "CNAME"<br>    target = "google._domainkey.provider.net"<br>  }<br>}</pre> | <pre>map(object({<br>    type       = string<br>    public_key = optional(string)<br>    key_type   = optional(string, "rsa")<br>    target     = optional(string)<br>    ttl        = optional(number)<br>    comment    = optional(string)<br>  }))</pre> | `null` | no |
| <a name="input_dmarc"></a> [dmarc](#input\_dmarc) | Helper for the DMARC TXT record published at `_dmarc`.<br><br>Example:<pre>hcl<br>dmarc = {<br>  policy    = "quarantine"<br>  rua       = ["mailto:dmarc@example.com"]<br>  spf_mode  = "relaxed"<br>  dkim_mode = "relaxed"<br>}</pre> | <pre>object({<br>    policy           = string<br>    subdomain_policy = optional(string)<br>    percent          = optional(number, 100)<br>    spf_mode         = optional(string, "relaxed")<br>    dkim_mode        = optional(string, "relaxed")<br>    rua              = optional(list(string), [])<br>    ruf              = optional(list(string), [])<br>    fo               = optional(string)<br>    ttl              = optional(number)<br>    comment          = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_email_routing_settings"></a> [email\_routing\_settings](#input\_email\_routing\_settings) | Email Routing settings for the zone, managed with `cloudflare_email_routing_settings`.<br><br>Example:<pre>hcl<br>email_routing_settings = {<br>  support_subaddress = true<br>}</pre> | <pre>object({<br>    support_subaddress = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_enable_dnssec"></a> [enable\_dnssec](#input\_enable\_dnssec) | Enable or disable DNSSEC. | `bool` | `false` | no |
| <a name="input_hostname_tls_settings"></a> [hostname\_tls\_settings](#input\_hostname\_tls\_settings) | Per-hostname TLS settings, managed with `cloudflare_hostname_tls_setting`.<br><br>Split into one bucket per `setting_id` (`ciphers`, `min_tls_version`,<br>`http2`) because each has a different `value` shape (a list of cipher<br>suite strings vs. a single string) and Terraform cannot type a single<br>list whose elements legitimately differ in shape.<br><br>Example:<pre>hcl<br>hostname_tls_settings = {<br>  min_tls_version = [<br>    { hostname = "app.example.com", value = "1.2" }<br>  ]<br>  ciphers = [<br>    { hostname = "app.example.com", value = ["ECDHE-RSA-AES128-GCM-SHA256"] }<br>  ]<br>}</pre> | <pre>object({<br>    ciphers = optional(list(object({<br>      hostname = string<br>      value    = list(string)<br>    })), [])<br><br>    min_tls_version = optional(list(object({<br>      hostname = string<br>      value    = string<br>    })), [])<br><br>    http2 = optional(list(object({<br>      hostname = string<br>      value    = string<br>    })), [])<br>  })</pre> | `{}` | no |
| <a name="input_mx"></a> [mx](#input\_mx) | Helper for MX records.<br><br>The helper creates one MX record for each combination of `names` and `servers`.<br>Example:<pre>hcl<br>mx = {<br>  names = ["@", "mail"]<br>  servers = [<br>    {<br>      host     = "mx1.provider.com"<br>      priority = 10<br>    },<br>    {<br>      host     = "mx2.provider.com"<br>      priority = 20<br>    }<br>  ]<br>}</pre> | <pre>object({<br>    names = optional(list(string), ["@"])<br>    servers = list(object({<br>      host     = string<br>      priority = number<br>    }))<br>    ttl     = optional(number)<br>    comment = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_nel_setting"></a> [nel\_setting](#input\_nel\_setting) | Network Error Logging setting for the zone, managed with `cloudflare_nel_setting`.<br><br>Example:<pre>hcl<br>nel_setting = {<br>  value = {<br>    enabled = true<br>  }<br>}</pre> | <pre>object({<br>    value = object({<br>      enabled = bool<br>    })<br>  })</pre> | `null` | no |
| <a name="input_page_rules"></a> [page\_rules](#input\_page\_rules) | Page Rules, managed with `cloudflare_page_rule`.<br><br>`actions` enumerates every Page Rule action as an optional field so each<br>entry constructs against one static type regardless of which actions it<br>sets (Terraform cannot type a list whose elements legitimately combine<br>different action keys any other way). The `cache_key_fields` action is<br>not covered by this helper — use `rulesets` (Cache Rules) for that, which<br>is also Cloudflare's recommended replacement for Page Rules generally.<br><br>Example:<pre>hcl<br>page_rules = [<br>  {<br>    key    = "force-https"<br>    target = "example.com/*"<br><br>    actions = {<br>      always_use_https = true<br>    }<br>  }<br>]</pre> | <pre>list(object({<br>    key      = string<br>    target   = string<br>    priority = optional(number)<br>    status   = optional(string)<br><br>    actions = object({<br>      always_use_https         = optional(bool)<br>      automatic_https_rewrites = optional(string)<br>      browser_cache_ttl        = optional(number)<br>      browser_check            = optional(string)<br>      bypass_cache_on_cookie   = optional(string)<br>      cache_by_device_type     = optional(string)<br>      cache_deception_armor    = optional(string)<br>      cache_level              = optional(string)<br>      cache_on_cookie          = optional(string)<br>      cache_ttl_by_status      = optional(map(string))<br>      edge_cache_ttl           = optional(number)<br>      email_obfuscation        = optional(string)<br>      explicit_cache_control   = optional(string)<br><br>      forwarding_url = optional(object({<br>        status_code = number<br>        url         = string<br>      }))<br><br>      host_header_override        = optional(string)<br>      ip_geolocation              = optional(string)<br>      mirage                      = optional(string)<br>      opportunistic_encryption    = optional(string)<br>      origin_error_page_pass_thru = optional(string)<br>      polish                      = optional(string)<br>      resolve_override            = optional(string)<br>      respect_strong_etag         = optional(string)<br>      response_buffering          = optional(string)<br>      rocket_loader               = optional(string)<br>      security_level              = optional(string)<br>      sort_query_string_for_cache = optional(string)<br>      ssl                         = optional(string)<br>      true_client_ip_header       = optional(string)<br>      waf                         = optional(string)<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_paused"></a> [paused](#input\_paused) | Indicates if the zone is only using Cloudflare DNS services. A true value means the zone will not receive security or performance benefits. | `bool` | `false` | no |
| <a name="input_records"></a> [records](#input\_records) | Zone's raw DNS records.<br><br>Use this input for records that are not covered by dedicated helpers.<br>Possible values:<br>  * for the `type` argument: "A", "AAAA", "CAA", "CERT", "CNAME", "DNSKEY", "DS", "HTTPS", "LOC", "MX", "NAPTR", "NS", "PTR", "SMIMEA", "SPF", "SRV", "SSHFP", "SVCB", "TLSA", "TXT", "URI".<br>  * for the `priority` argument: between 0 and 65535.<br>  * possible values for the `ttl` argument: between 60 and 86400, or 1 for automatic.<br>  * `comment` is an optional Cloudflare DNS record comment. | <pre>list(object({<br>    record_name = string<br>    type        = string<br>    name        = optional(string)<br>    value       = optional(string)<br>    comment     = optional(string)<br>    data = optional(object({<br>      algorithm      = optional(number)<br>      altitude       = optional(number)<br>      certificate    = optional(string)<br>      content        = optional(string)<br>      digest         = optional(string)<br>      digest_type    = optional(number)<br>      fingerprint    = optional(string)<br>      flags          = optional(string)<br>      key_tag        = optional(number)<br>      lat_degrees    = optional(number)<br>      lat_direction  = optional(string)<br>      lat_minutes    = optional(number)<br>      lat_seconds    = optional(number)<br>      long_degrees   = optional(number)<br>      long_direction = optional(string)<br>      long_minutes   = optional(number)<br>      long_seconds   = optional(number)<br>      matching_type  = optional(number)<br>      name           = optional(string)<br>      order          = optional(number)<br>      port           = optional(number)<br>      precision_horz = optional(number)<br>      precision_vert = optional(number)<br>      preference     = optional(number)<br>      priority       = optional(number)<br>      proto          = optional(string)<br>      protocol       = optional(number)<br>      public_key     = optional(string)<br>      regex          = optional(string)<br>      replacement    = optional(string)<br>      selector       = optional(number)<br>      service        = optional(string)<br>      size           = optional(number)<br>      tag            = optional(string)<br>      target         = optional(string)<br>      type           = optional(number)<br>      usage          = optional(number)<br>      value          = optional(string)<br>      weight         = optional(number)<br>    }))<br>    priority = optional(number)<br>    ttl      = optional(number)<br>    proxied  = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_regional_tiered_cache"></a> [regional\_tiered\_cache](#input\_regional\_tiered\_cache) | Regional Tiered Cache setting for the zone, managed with `cloudflare_regional_tiered_cache`.<br><br>Example:<pre>hcl<br>regional_tiered_cache = {<br>  value = "on"<br>}</pre> | <pre>object({<br>    value = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Cloudflare Workers routes bound to this zone, managed with<br>`cloudflare_workers_route`.<br><br>Each entry binds a URL pattern within this zone to an existing Worker<br>script name.<br><br>Example:<pre>hcl<br>routes = [<br>  {<br>    pattern = "api.example.com/*"<br>    script  = "my-worker"<br>  }<br>]</pre> | <pre>list(object({<br>    pattern = string<br>    script  = string<br>  }))</pre> | `[]` | no |
| <a name="input_rulesets"></a> [rulesets](#input\_rulesets) | Cloudflare Ruleset Engine wrapper.<br><br>Each item creates one `cloudflare_ruleset` resource.<br>Supported scopes:<br>  * zone-level rulesets when `account_level = false` or omitted<br>  * account-level rulesets when `account_level = true`<br><br>This wrapper accepts a simplified input shape and internally converts it<br>to the Cloudflare provider v5 resource schema. | <pre>list(object({<br>    key           = string<br>    name          = string<br>    description   = optional(string)<br>    kind          = string<br>    phase         = string<br>    account_level = optional(bool)<br><br>    rules = optional(list(object({<br>      ref         = string<br>      action      = string<br>      expression  = optional(string)<br>      description = optional(string)<br>      enabled     = optional(bool)<br><br>      action_parameters = optional(object({<br>        cache                      = optional(bool)<br>        origin_error_page_passthru = optional(bool)<br>        respect_strong_etags       = optional(bool)<br>        version                    = optional(string)<br><br>        response = optional(object({<br>          status_code  = optional(number)<br>          content      = optional(string)<br>          content_type = optional(string)<br>        }))<br><br>        from_value = optional(object({<br>          status_code           = optional(number)<br>          preserve_query_string = optional(bool)<br><br>          target_url = optional(object({<br>            value      = optional(string)<br>            expression = optional(string)<br>          }))<br>        }))<br><br>        edge_ttl = optional(object({<br>          mode    = string<br>          default = optional(number)<br><br>          status_code_ttl = optional(list(object({<br>            status_code = optional(number)<br>            status_code_range = optional(object({<br>              from = number<br>              to   = number<br>            }))<br>            value = number<br>          })))<br>        }))<br><br>        browser_ttl = optional(object({<br>          mode    = string<br>          default = optional(number)<br>        }))<br><br>        serve_stale = optional(object({<br>          disable_stale_while_updating = optional(bool)<br>        }))<br><br>        cache_key = optional(object({<br>          ignore_query_strings_order = optional(bool)<br>          cache_by_device_type       = optional(bool)<br>        }))<br><br>        uri = optional(object({<br>          path = optional(object({<br>            value      = optional(string)<br>            expression = optional(string)<br>          }))<br>        }))<br>      }))<br><br>      logging = optional(object({<br>        enabled = bool<br>      }))<br><br>      ratelimit = optional(object({<br>        characteristics            = list(string)<br>        period                     = number<br>        requests_per_period        = number<br>        mitigation_timeout         = number<br>        requests_to_origin         = optional(bool)<br>        score_per_period           = optional(number)<br>        score_response_header_name = optional(string)<br>        counting_expression        = optional(string)<br>      }))<br><br>      exposed_credential_check = optional(object({<br>        username_expression = string<br>        password_expression = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_spf"></a> [spf](#input\_spf) | Helper for an SPF TXT record.<br><br>This helper is semantic: instead of passing raw SPF terms, provide inputs such as<br>`includes`, `ip4s`, `ip6s`, `a`, `mx`, `redirect` and `all`.<br><br>Example:<pre>hcl<br>spf = {<br>  includes = ["_spf.google.com", "spf.mailgun.org"]<br>  ip4s     = ["192.0.2.10", "198.51.100.0/24"]<br>  all      = "softfail"<br>}</pre> | <pre>object({<br>    name     = optional(string, "@")<br>    includes = optional(list(string), [])<br>    ip4s     = optional(list(string), [])<br>    ip6s     = optional(list(string), [])<br>    a        = optional(bool, false)<br>    mx       = optional(bool, false)<br>    redirect = optional(string)<br>    all      = optional(string, "fail")<br>    ttl      = optional(number)<br>    comment  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_tiered_cache"></a> [tiered\_cache](#input\_tiered\_cache) | Smart Tiered Cache setting for the zone, managed with `cloudflare_tiered_cache`.<br><br>Example:<pre>hcl<br>tiered_cache = {<br>  value = "on"<br>}</pre> | <pre>object({<br>    value = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_tlsrpt"></a> [tlsrpt](#input\_tlsrpt) | Helper for the SMTP TLS Reporting TXT record published at `_smtp._tls`.<br><br>Example:<pre>hcl<br>tlsrpt = {<br>  rua = ["mailto:tlsrpt@example.com"]<br>}</pre> | <pre>object({<br>    rua     = list(string)<br>    ttl     = optional(number)<br>    comment = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | A full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup. Possible values: `full`, `partial`.<br>To learn more and choose the right configuration for you, see the documentation about [full](https://developers.cloudflare.com/dns/zone-setups/full-setup/) or [partial CNAME](https://developers.cloudflare.com/dns/zone-setups/partial-setup/) setups. | `string` | `"full"` | no |
| <a name="input_universal_ssl_setting"></a> [universal\_ssl\_setting](#input\_universal\_ssl\_setting) | Universal SSL setting for the zone, managed with `cloudflare_universal_ssl_setting`.<br><br>Example:<pre>hcl<br>universal_ssl_setting = {<br>  enabled = true<br>}</pre> | <pre>object({<br>    enabled = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The DNS zone name which will be added, e.g. example.com. | `string` | n/a | yes |
| <a name="input_zone_cache_reserve"></a> [zone\_cache\_reserve](#input\_zone\_cache\_reserve) | Cache Reserve setting for the zone, managed with `cloudflare_zone_cache_reserve`.<br><br>Example:<pre>hcl<br>zone_cache_reserve = {<br>  value = "on"<br>}</pre> | <pre>object({<br>    value = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_zone_cache_variants"></a> [zone\_cache\_variants](#input\_zone\_cache\_variants) | Cache Variants setting for the zone, managed with `cloudflare_zone_cache_variants`.<br><br>Each key lists the alternate MIME types Cloudflare may serve instead of the<br>source image format, when the client's Accept header allows it.<br><br>Example:<pre>hcl<br>zone_cache_variants = {<br>  value = {<br>    webp = ["image/jpeg", "image/avif"]<br>  }<br>}</pre> | <pre>object({<br>    value = optional(object({<br>      avif = optional(list(string))<br>      bmp  = optional(list(string))<br>      gif  = optional(list(string))<br>      jp2  = optional(list(string))<br>      jpeg = optional(list(string))<br>      jpg  = optional(list(string))<br>      jpg2 = optional(list(string))<br>      png  = optional(list(string))<br>      tif  = optional(list(string))<br>      tiff = optional(list(string))<br>      webp = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_zone_dns_settings"></a> [zone\_dns\_settings](#input\_zone\_dns\_settings) | DNS settings for the zone, managed with `cloudflare_zone_dns_settings`.<br><br>Example:<pre>hcl<br>zone_dns_settings = {<br>  flatten_all_cnames = true<br>  zone_mode          = "dns_only"<br>}</pre> | <pre>object({<br>    flatten_all_cnames  = optional(bool)<br>    foundation_dns      = optional(bool)<br>    multi_provider      = optional(bool)<br>    secondary_overrides = optional(bool)<br>    ns_ttl              = optional(number)<br>    zone_mode           = optional(string)<br><br>    internal_dns = optional(object({<br>      reference_zone_id = string<br>    }))<br><br>    nameservers = optional(object({<br>      type              = string<br>      nameserver_set_id = optional(string)<br>      ns_set            = optional(number)<br>    }))<br><br>    soa = optional(object({<br>      expire  = optional(number)<br>      min_ttl = optional(number)<br>      mname   = optional(string)<br>      refresh = optional(number)<br>      retry   = optional(number)<br>      rname   = optional(string)<br>      ttl     = optional(number)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_zone_hold"></a> [zone\_hold](#input\_zone\_hold) | Zone Hold for the zone, managed with `cloudflare_zone_hold`.<br><br>Blocks the creation and activation of any zone using this zone's hostname.<br>Declaring this object enables the hold; omitting it (the default) leaves no<br>hold in place. Scheduling a temporary release via `hold_after` is not<br>supported by this helper.<br><br>Example:<pre>hcl<br>zone_hold = {<br>  include_subdomains = true<br>}</pre> | <pre>object({<br>    include_subdomains = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_zone_lockdowns"></a> [zone\_lockdowns](#input\_zone\_lockdowns) | Zone Lockdown rules, managed with `cloudflare_zone_lockdown`.<br><br>Restricts access to the listed `urls` to the IPs or IP ranges declared in<br>`configurations`.<br><br>Example:<pre>hcl<br>zone_lockdowns = [<br>  {<br>    key  = "admin-panel"<br>    urls = ["admin.example.com/*"]<br><br>    configurations = [<br>      {<br>        target = "ip"<br>        value  = "198.51.100.4"<br>      }<br>    ]<br>  }<br>]</pre> | <pre>list(object({<br>    key         = string<br>    urls        = list(string)<br>    description = optional(string)<br>    paused      = optional(bool)<br>    priority    = optional(number)<br><br>    configurations = list(object({<br>      target = string<br>      value  = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_zone_settings"></a> [zone\_settings](#input\_zone\_settings) | Zone settings applied with `cloudflare_zone_setting`.<br><br>Some settings use `value`, while others use `enabled`. | <pre>list(object({<br>    setting_id = string<br>    value      = optional(string)<br>    enabled    = optional(bool)<br>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_algorithm"></a> [algorithm](#output\_algorithm) | Zone DNSSEC algorithm. |
| <a name="output_digest"></a> [digest](#output\_digest) | Zone DNSSEC digest. |
| <a name="output_digest_algorithm"></a> [digest\_algorithm](#output\_digest\_algorithm) | Digest algorithm used for Zone DNSSEC. |
| <a name="output_digest_type"></a> [digest\_type](#output\_digest\_type) | Digest Type for the Zone DNSSEC. |
| <a name="output_dnssec_status"></a> [dnssec\_status](#output\_dnssec\_status) | The status of the Zone DNSSEC. |
| <a name="output_ds"></a> [ds](#output\_ds) | DS for the Zone DNSSEC. |
| <a name="output_flags"></a> [flags](#output\_flags) | Zone DNSSEC flags. |
| <a name="output_hostname_tls_setting_ids"></a> [hostname\_tls\_setting\_ids](#output\_hostname\_tls\_setting\_ids) | The hostname TLS setting IDs, keyed by setting\_id then hostname. |
| <a name="output_key_tag"></a> [key\_tag](#output\_key\_tag) | Key Tag for the Zone DNSSEC. |
| <a name="output_key_type"></a> [key\_type](#output\_key\_type) | Key type used for Zone DNSSEC. |
| <a name="output_meta"></a> [meta](#output\_meta) | Map of booleans, indicating some zone statuses or flags. |
| <a name="output_modified_on"></a> [modified\_on](#output\_modified\_on) | Zone DNSSEC updated time. |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | Cloudflare-assigned name servers. This is only populated for zones that use Cloudflare DNS. |
| <a name="output_page_rule_ids"></a> [page\_rule\_ids](#output\_page\_rule\_ids) | The Page Rule IDs keyed by the module's page\_rules key. |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | Public Key for the Zone DNSSEC. |
| <a name="output_record_ids"></a> [record\_ids](#output\_record\_ids) | The record IDs keyed by the module's managed record key. |
| <a name="output_record_modified_on"></a> [record\_modified\_on](#output\_record\_modified\_on) | The RFC3339 timestamp of when the records were last modified. |
| <a name="output_record_names"></a> [record\_names](#output\_record\_names) | The managed DNS record names keyed by the module's managed record key. |
| <a name="output_record_proxiable"></a> [record\_proxiable](#output\_record\_proxiable) | Shows whether these records can be proxied. This must be true if setting proxied = true. |
| <a name="output_status"></a> [status](#output\_status) | Status of the zone. Valid values: active, pending, initializing, moved. |
| <a name="output_vanity_name_servers"></a> [vanity\_name\_servers](#output\_vanity\_name\_servers) | List of Vanity Nameservers, if set. |
| <a name="output_verification_key"></a> [verification\_key](#output\_verification\_key) | Contains the TXT record value to validate domain ownership. This is only populated for zones of type partial. |
| <a name="output_workers_route_ids"></a> [workers\_route\_ids](#output\_workers\_route\_ids) | The Workers Route IDs keyed by the route pattern. |
| <a name="output_zone_hold_status"></a> [zone\_hold\_status](#output\_zone\_hold\_status) | Whether a Zone Hold is currently active, if zone\_hold was declared. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The zone ID. |
| <a name="output_zone_lockdown_ids"></a> [zone\_lockdown\_ids](#output\_zone\_lockdown\_ids) | The Zone Lockdown rule IDs keyed by the module's zone\_lockdowns key. |

### Examples

```hcl
module "zone" {
  source = "../.."

  zone       = var.zone
  account_id = var.account_id

  comment = "Managed by Terraform"

  records = [
    {
      record_name = "bastion-example-a"
      name        = "bastion-example"
      value       = "1.1.1.1"
      type        = "A"
      ttl         = 1
    },
    {
      record_name = "api-example-a"
      name        = "api-example"
      value       = "1.1.1.1"
      type        = "A"
      ttl         = 1
    }
  ]

  mx = {
    names = ["@"]
    servers = [
      {
        host     = "mx1.mail.example.net"
        priority = 10
      },
      {
        host     = "mx2.mail.example.net"
        priority = 20
      }
    ]
    ttl = 3600
  }

  spf = {
    includes = ["_spf.google.com", "spf.mailgun.org"]
    ip4s     = ["192.0.2.10"]
    all      = "softfail"
    ttl      = 3600
  }

  dmarc = {
    policy    = "quarantine"
    rua       = ["mailto:dmarc@example.com"]
    spf_mode  = "relaxed"
    dkim_mode = "relaxed"
    percent   = 100
    ttl       = 3600
  }

  tlsrpt = {
    rua = ["mailto:tlsrpt@example.com"]
    ttl = 3600
  }

  dkim = {
    selector1 = {
      type       = "TXT"
      public_key = "REPLACE_WITH_YOUR_DKIM_PUBLIC_KEY"
      ttl        = 3600
    }

    google = {
      type   = "CNAME"
      target = "google._domainkey.mail.provider.example.net"
      ttl    = 3600
    }
  }

  zone_settings = [
    {
      setting_id = "always_use_https"
      enabled    = true
    }
  ]

  rulesets = [
    {
      key   = "zone-http-config"
      name  = "Zone HTTP configuration"
      kind  = "zone"
      phase = "http_request_dynamic_redirect"

      rules = [
        {
          ref         = "redirect-http-to-https"
          description = "Redirect all HTTP requests to HTTPS"
          action      = "redirect"
          expression  = "(http.request.scheme eq \"http\")"
          enabled     = true

          action_parameters = {
            from_value = {
              status_code           = 301
              preserve_query_string = true

              target_url = {
                expression = "concat(\"https://\", http.host, http.request.uri.path)"
              }
            }
          }
        }
      ]
    }
  ]
}
```

<!-- END_TF_DOCS -->


### Importing existing zone to IaaC

if the domain exists and already has records, don't worry about importing it into terraform using this module.

In the first step you need to create a [zone](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) to tfstate:
```
terraform import cloudflare_zone.example <zone_id>
```
according to [official documentation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone#import).

When we have our zone in tfstate, we have 2 steps to done.

1) As first, we can run our helper bash script to generate json.
A bash script dump records from exists zone DNS to json, just copy the generated json to the `records` variable.
Script require `CLOUDFLARE_API_TOKEN` as a environment variable and domain name as a parameter.

For Example:
```
CLOUDFLARE_API_TOKEN=1234567890abcdef1234567890abcdef; bin/import_zone.sh "acme.sh"
```

2) The second step is more complex because you need to import existing records into your `tfstate`.
To make it as simple as possible, you can use a our hook:
```
#!/bin/bash

DOMAIN="$1"

zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq \
  -r '{"result"}[] | .[0] | .id')


records=$(curl -s -L -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type:application/json" | jq  -r '.result[] | "\(.name)_\(.type)_\(.id)|\(.id)"')


for i in $records
do
  s=$(echo $i | awk -F'|' '{print $1}')
  t=$(echo $i | awk -F'|' '{print $2}')
  terraform import cloudflare_record.this[\"${s}\"] ${zoneid}/${t}
done
```
This script is fully compatible with our `bin/import_zone.sh` script and creates the same style object's names in `tfstate`.
As previously, hook require `CLOUDFLARE_API_TOKEN` as a environment variable and domain name as a parameter.

To more information about importing [cloudflare_record](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record)
please visit to [official documentation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record#import).



<!-- references -->

[repo_link]: https://github.com/Infrastrukturait/terraform-cloudflare-zone
