## Submodules

Submodules included to root module that can be called independent:

- [single-record](https://github.com/Infrastrukturait/terraform-cloudflare-zone/tree/main/modules/single-record) - **Deprecated**, use the root module's `manage_zone = false` + `record` inputs instead. Was a small sub-module to facilitate the creation of a single record on an existing zone, without creating/owning the zone itself.
