## Notes

* The `name` and the `data.name` argument values default to `@` (root). This is actually the default behavior, but only for the value of the `data.name` argument when you are not using the module.
* The `data` argument is fully supported. The `value` argument takes precedence over the `data` argument to avoid errors if two arguments are accidentally given at the same time, since only one of them can be given at the same time.
* The `ttl` argument value defaults to `1` (automatic). This is actually the default behavior.
* The `ttl` argument value is forced to `1` (automatic), regardless of explicitly set value, if you set the `proxied` argument value to `true`.
* The `proxied` argument value defaults to `false`. This is actually the default behavior. You must explicitly set this argument value to `true` for the records that you want to proxy through Cloudflare.
* The `proxied` argument value is forced to `false` for unsupported record types, regardless of explicitly set value.
* The `proxied` argument value is forced to `false` for wildcard records for non-enterprise plans, regardless of explicitly set value, because non-enterprise customers can create but not proxy wildcard records.
* To create only each record without create whole zone, you can just use simple submodule [single-record](https://github.com/Infrastrukturait/terraform-cloudflare-zone/tree/main/modules/single-record).

## Cloudflare provider v5 resource naming

This module targets the Cloudflare provider **v5** (a ground-up rewrite of
v4, generated from Cloudflare's OpenAPI spec). If you migrate existing v4
configurations to this module, note these changes (full list: [v5 upgrade
guide](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/guides/version-5-upgrade)):

| v4 resource | v5 status |
|---|---|
| `cloudflare_transform_rule` / `cloudflare_headers_transform_rule` | **removed** — use `cloudflare_ruleset` with a transform phase (this module's `rulesets` input) |
| `cloudflare_url_forwarding` | **removed** — use `cloudflare_ruleset` with phase `http_response_redirects` |
| `cloudflare_managed_headers` | renamed `cloudflare_managed_transforms` |
| `cloudflare_custom_page` | replaced by `cloudflare_custom_pages` + `cloudflare_custom_page_asset` |
| `cloudflare_zone_settings_override` | **removed** — one `cloudflare_zone_setting` per setting (this module's `zone_settings` input) |
| `cloudflare_access_*` | renamed `cloudflare_zero_trust_access_*` |
| `cloudflare_tunnel` | renamed `cloudflare_zero_trust_tunnel_cloudflared` |
