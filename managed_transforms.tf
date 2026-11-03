resource "cloudflare_managed_transforms" "this" {
  count = var.managed_transforms == null ? 0 : 1

  zone_id = local.zone_id

  # An omitted direction (null) is left unmanaged; an explicitly empty list
  # must still be sent as [] (not null) so it actively clears that
  # direction's transforms instead of being skipped by the provider.
  managed_request_headers = try(var.managed_transforms.request, null) == null ? null : [
    for id in var.managed_transforms.request : {
      id      = id
      enabled = true
    }
  ]

  managed_response_headers = try(var.managed_transforms.response, null) == null ? null : [
    for id in var.managed_transforms.response : {
      id      = id
      enabled = true
    }
  ]
}
