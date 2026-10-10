locals {
  zone_lockdowns_by_key = {
    for lockdown in var.zone_lockdowns : lockdown.key => lockdown
  }
}

resource "cloudflare_zone_lockdown" "this" {
  for_each = local.zone_lockdowns_by_key

  zone_id     = local.zone_id
  urls        = each.value.urls
  description = try(each.value.description, null)
  paused      = try(each.value.paused, null)
  priority    = try(each.value.priority, null)

  configurations = [
    for cfg in each.value.configurations : {
      target = cfg.target
      value  = cfg.value
    }
  ]
}
