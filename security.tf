resource "cloudflare_bot_management" "this" {
  count = var.bot_management == null ? 0 : 1

  zone_id                         = local.zone_id
  fight_mode                      = try(var.bot_management.fight_mode, null)
  sbfm_definitely_automated       = try(var.bot_management.sbfm_definitely_automated, null)
  sbfm_likely_automated           = try(var.bot_management.sbfm_likely_automated, null)
  sbfm_static_resource_protection = try(var.bot_management.sbfm_static_resource_protection, null)
  sbfm_verified_bots              = try(var.bot_management.sbfm_verified_bots, null)
  content_bots_protection         = try(var.bot_management.content_bots_protection, null)
  crawler_protection              = try(var.bot_management.crawler_protection, null)
  ai_bots_protection              = try(var.bot_management.ai_bots_protection, null)
  ai_training                     = try(var.bot_management.ai_training, null)
  ai_user                         = try(var.bot_management.ai_user, null)
  aisearch                        = try(var.bot_management.aisearch, null)
  bm_cookie_enabled               = try(var.bot_management.bm_cookie_enabled, null)
  enable_js                       = try(var.bot_management.enable_js, null)
  is_robots_txt_managed           = try(var.bot_management.is_robots_txt_managed, null)
  optimize_wordpress              = try(var.bot_management.optimize_wordpress, null)
  cf_robots_variant               = try(var.bot_management.cf_robots_variant, null)
  jsd_api_results_enabled         = try(var.bot_management.jsd_api_results_enabled, null)
  suppress_session_score          = try(var.bot_management.suppress_session_score, null)
}

resource "cloudflare_access_rule" "this" {
  for_each = { for r in var.ip_access_rules : r.key => r }

  zone_id = local.zone_id
  mode    = each.value.mode
  notes   = try(each.value.notes, null)

  configuration = {
    target = each.value.target
    value  = each.value.value
  }
}

resource "cloudflare_user_agent_blocking_rule" "this" {
  for_each = { for r in var.user_agent_blocking_rules : r.key => r }

  zone_id     = local.zone_id
  mode        = each.value.mode
  description = try(each.value.description, null)
  paused      = try(each.value.paused, null)

  configuration = {
    target = "ua"
    value  = each.value.value
  }
}
