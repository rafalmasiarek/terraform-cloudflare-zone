resource "cloudflare_url_normalization_settings" "this" {
  count = var.url_normalization == null ? 0 : 1

  zone_id = local.zone_id
  scope   = var.url_normalization.scope
  type    = var.url_normalization.type
}
