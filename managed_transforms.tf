resource "cloudflare_managed_transforms" "this" {
  count = var.managed_transforms == null ? 0 : 1

  zone_id = local.zone_id

  managed_request_headers = [
    for id in coalesce(try(var.managed_transforms.request, null), []) : {
      id      = id
      enabled = true
    }
  ]

  managed_response_headers = [
    for id in coalesce(try(var.managed_transforms.response, null), []) : {
      id      = id
      enabled = true
    }
  ]
}
