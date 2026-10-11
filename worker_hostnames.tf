locals {
  worker_hostnames_by_key = {
    for wh in var.worker_hostnames : wh.hostname => wh
  }
}

resource "cloudflare_workers_custom_domain" "this" {
  for_each = local.worker_hostnames_by_key

  account_id = var.account_id
  zone_id    = local.zone_id
  hostname   = each.value.hostname
  service    = each.value.script
}
