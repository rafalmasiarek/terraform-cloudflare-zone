locals {
  page_rules_by_key = {
    for rule in var.page_rules : rule.key => rule
  }
}

resource "cloudflare_page_rule" "this" {
  for_each = local.page_rules_by_key

  zone_id  = local.zone_id
  target   = each.value.target
  priority = try(each.value.priority, null)
  status   = try(each.value.status, null)

  actions = {
    always_use_https         = each.value.actions.always_use_https
    automatic_https_rewrites = each.value.actions.automatic_https_rewrites
    browser_cache_ttl        = each.value.actions.browser_cache_ttl
    browser_check            = each.value.actions.browser_check
    bypass_cache_on_cookie   = each.value.actions.bypass_cache_on_cookie
    cache_by_device_type     = each.value.actions.cache_by_device_type
    cache_deception_armor    = each.value.actions.cache_deception_armor
    cache_level              = each.value.actions.cache_level
    cache_on_cookie          = each.value.actions.cache_on_cookie
    cache_ttl_by_status      = each.value.actions.cache_ttl_by_status
    edge_cache_ttl           = each.value.actions.edge_cache_ttl
    email_obfuscation        = each.value.actions.email_obfuscation
    explicit_cache_control   = each.value.actions.explicit_cache_control

    forwarding_url = each.value.actions.forwarding_url != null ? {
      status_code = each.value.actions.forwarding_url.status_code
      url         = each.value.actions.forwarding_url.url
    } : null

    host_header_override        = each.value.actions.host_header_override
    ip_geolocation              = each.value.actions.ip_geolocation
    mirage                      = each.value.actions.mirage
    opportunistic_encryption    = each.value.actions.opportunistic_encryption
    origin_error_page_pass_thru = each.value.actions.origin_error_page_pass_thru
    polish                      = each.value.actions.polish
    resolve_override            = each.value.actions.resolve_override
    respect_strong_etag         = each.value.actions.respect_strong_etag
    response_buffering          = each.value.actions.response_buffering
    rocket_loader               = each.value.actions.rocket_loader
    security_level              = each.value.actions.security_level
    sort_query_string_for_cache = each.value.actions.sort_query_string_for_cache
    ssl                         = each.value.actions.ssl
    true_client_ip_header       = each.value.actions.true_client_ip_header
    waf                         = each.value.actions.waf
  }
}
