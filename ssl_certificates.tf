resource "cloudflare_origin_ca_certificate" "this" {
  for_each = coalesce(var.origin_ca_certificates, {})

  csr                = each.value.csr
  hostnames          = each.value.hostnames
  request_type       = each.value.request_type
  requested_validity = try(each.value.requested_validity, null)
}

resource "cloudflare_authenticated_origin_pulls_certificate" "this" {
  count = var.aop_certificate == null ? 0 : 1

  zone_id     = local.zone_id
  certificate = var.aop_certificate.certificate
  private_key = var.aop_certificate.private_key
}

resource "cloudflare_authenticated_origin_pulls_hostname_certificate" "this" {
  # var.aop_hostname_certificates is sensitive, so its keys can't be used
  # directly as a for_each source; only the module's own map keys (not the
  # certificate/private_key values) are declassified here.
  for_each = nonsensitive(toset(keys(coalesce(var.aop_hostname_certificates, {}))))

  zone_id     = local.zone_id
  certificate = var.aop_hostname_certificates[each.key].certificate
  private_key = var.aop_hostname_certificates[each.key].private_key
}

resource "cloudflare_authenticated_origin_pulls" "this" {
  # Uploading a hostname certificate does not activate per-hostname AOP on
  # its own; this association + enablement step is required separately.
  for_each = nonsensitive(toset(keys(coalesce(var.aop_hostname_certificates, {}))))

  zone_id = local.zone_id

  config = [{
    cert_id  = cloudflare_authenticated_origin_pulls_hostname_certificate.this[each.key].id
    hostname = var.aop_hostname_certificates[each.key].hostname
    enabled  = try(var.aop_hostname_certificates[each.key].enabled, true)
  }]
}
