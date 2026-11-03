resource "cloudflare_list" "this" {
  for_each = { for l in var.lists : l.key => l }

  account_id  = var.account_id
  kind        = each.value.kind
  name        = each.value.name
  description = try(each.value.description, null)

  items = [
    for item in coalesce(try(each.value.items, null), []) : {
      ip      = item.ip
      comment = try(item.comment, null)
    }
  ]
}
