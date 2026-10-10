locals {
  hostname_tls_ciphers_by_key = {
    for s in var.hostname_tls_settings.ciphers : s.hostname => s
  }

  hostname_tls_min_tls_version_by_key = {
    for s in var.hostname_tls_settings.min_tls_version : s.hostname => s
  }

  hostname_tls_http2_by_key = {
    for s in var.hostname_tls_settings.http2 : s.hostname => s
  }
}

resource "cloudflare_hostname_tls_setting" "ciphers" {
  for_each = local.hostname_tls_ciphers_by_key

  zone_id    = local.zone_id
  hostname   = each.value.hostname
  setting_id = "ciphers"
  value      = each.value.value
}

resource "cloudflare_hostname_tls_setting" "min_tls_version" {
  for_each = local.hostname_tls_min_tls_version_by_key

  zone_id    = local.zone_id
  hostname   = each.value.hostname
  setting_id = "min_tls_version"
  value      = each.value.value
}

resource "cloudflare_hostname_tls_setting" "http2" {
  for_each = local.hostname_tls_http2_by_key

  zone_id    = local.zone_id
  hostname   = each.value.hostname
  setting_id = "http2"
  value      = each.value.value
}
