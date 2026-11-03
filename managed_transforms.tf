resource "cloudflare_managed_transforms" "this" {
  count = var.managed_transforms == null ? 0 : 1

  zone_id = local.zone_id

  managed_request_headers = length(coalesce(try(var.managed_transforms.request, null), [])) > 0 ? [
    for id in var.managed_transforms.request : {
      id      = id
      enabled = true
    }
  ] : null

  managed_response_headers = length(coalesce(try(var.managed_transforms.response, null), [])) > 0 ? [
    for id in var.managed_transforms.response : {
      id      = id
      enabled = true
    }
  ] : null
}
