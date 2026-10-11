locals {
  workers_routes_by_key = {
    for route in var.worker_routes : route.pattern => route
  }
}

resource "cloudflare_workers_route" "this" {
  for_each = local.workers_routes_by_key

  zone_id = local.zone_id
  pattern = each.value.pattern
  script  = each.value.script
}
