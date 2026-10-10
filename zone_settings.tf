resource "cloudflare_universal_ssl_setting" "this" {
  count = var.universal_ssl_setting != null ? 1 : 0

  zone_id = local.zone_id
  enabled = try(var.universal_ssl_setting.enabled, null)
}

resource "cloudflare_zone_cache_reserve" "this" {
  count = var.zone_cache_reserve != null ? 1 : 0

  zone_id = local.zone_id
  value   = try(var.zone_cache_reserve.value, null)
}

resource "cloudflare_tiered_cache" "this" {
  count = var.tiered_cache != null ? 1 : 0

  zone_id = local.zone_id
  value   = try(var.tiered_cache.value, null)
}

resource "cloudflare_regional_tiered_cache" "this" {
  count = var.regional_tiered_cache != null ? 1 : 0

  zone_id = local.zone_id
  value   = try(var.regional_tiered_cache.value, null)
}

resource "cloudflare_zone_cache_variants" "this" {
  count = var.zone_cache_variants != null ? 1 : 0

  zone_id = local.zone_id

  value = {
    avif = try(var.zone_cache_variants.value.avif, null)
    bmp  = try(var.zone_cache_variants.value.bmp, null)
    gif  = try(var.zone_cache_variants.value.gif, null)
    jp2  = try(var.zone_cache_variants.value.jp2, null)
    jpeg = try(var.zone_cache_variants.value.jpeg, null)
    jpg  = try(var.zone_cache_variants.value.jpg, null)
    jpg2 = try(var.zone_cache_variants.value.jpg2, null)
    png  = try(var.zone_cache_variants.value.png, null)
    tif  = try(var.zone_cache_variants.value.tif, null)
    tiff = try(var.zone_cache_variants.value.tiff, null)
    webp = try(var.zone_cache_variants.value.webp, null)
  }
}

resource "cloudflare_zone_dns_settings" "this" {
  count = var.zone_dns_settings != null ? 1 : 0

  zone_id = local.zone_id

  flatten_all_cnames  = try(var.zone_dns_settings.flatten_all_cnames, null)
  foundation_dns      = try(var.zone_dns_settings.foundation_dns, null)
  multi_provider      = try(var.zone_dns_settings.multi_provider, null)
  secondary_overrides = try(var.zone_dns_settings.secondary_overrides, null)
  ns_ttl              = try(var.zone_dns_settings.ns_ttl, null)
  zone_mode           = try(var.zone_dns_settings.zone_mode, null)

  internal_dns = try(var.zone_dns_settings.internal_dns, null) != null ? {
    reference_zone_id = var.zone_dns_settings.internal_dns.reference_zone_id
  } : null

  nameservers = try(var.zone_dns_settings.nameservers, null) != null ? {
    type              = var.zone_dns_settings.nameservers.type
    nameserver_set_id = try(var.zone_dns_settings.nameservers.nameserver_set_id, null)
    ns_set            = try(var.zone_dns_settings.nameservers.ns_set, null)
  } : null

  soa = try(var.zone_dns_settings.soa, null) != null ? {
    expire  = try(var.zone_dns_settings.soa.expire, null)
    min_ttl = try(var.zone_dns_settings.soa.min_ttl, null)
    mname   = try(var.zone_dns_settings.soa.mname, null)
    refresh = try(var.zone_dns_settings.soa.refresh, null)
    retry   = try(var.zone_dns_settings.soa.retry, null)
    rname   = try(var.zone_dns_settings.soa.rname, null)
    ttl     = try(var.zone_dns_settings.soa.ttl, null)
  } : null
}

resource "cloudflare_email_routing_settings" "this" {
  count = var.email_routing_settings != null ? 1 : 0

  zone_id            = local.zone_id
  support_subaddress = try(var.email_routing_settings.support_subaddress, null)
}

resource "cloudflare_nel_setting" "this" {
  count = var.nel_setting != null ? 1 : 0

  zone_id = local.zone_id

  value = {
    enabled = var.nel_setting.value.enabled
  }
}

resource "cloudflare_authenticated_origin_pulls_settings" "this" {
  count = var.authenticated_origin_pulls_settings != null ? 1 : 0

  zone_id = local.zone_id
  enabled = try(var.authenticated_origin_pulls_settings.enabled, null)
}

resource "cloudflare_zone_hold" "this" {
  count = var.zone_hold != null ? 1 : 0

  zone_id            = local.zone_id
  include_subdomains = try(var.zone_hold.include_subdomains, false)
}
