
# cloudflare-single-record

[![WeSupportUkraine](https://raw.githubusercontent.com/Infrastrukturait/WeSupportUkraine/main/banner.svg)](https://github.com/Infrastrukturait/WeSupportUkraine)
## About

**Deprecated.** Use the root module's `manage_zone = false` + `record` inputs instead — same single-record use case, plus FQDN/TXT normalization and the rest of the root module's features, with no separate module to keep in sync.

Terraform module to provision a CloudFlare zone with DNS record managment
## License

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

```text
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
## Authors
- Rafał Masiarek | [website](https://masiarek.pl) | [email](mailto:rafal@masiarek.pl) | [github](https://github.com/rafalmasiarek)
<!-- BEGIN_TF_DOCS -->
## Documentation


### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 3.23 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 3.30.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [cloudflare_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_zones.domain](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_overwrite"></a> [allow\_overwrite](#input\_allow\_overwrite) | Allow creation of this record in Terraform to overwrite an existing record, if any. | `bool` | `false` | no |
| <a name="input_data"></a> [data](#input\_data) | Map of metadata for a record. | <pre>list(object({<br>    algorithm      = optional(number)<br>    altitude       = optional(number)<br>    certificate    = optional(string)<br>    content        = optional(string)<br>    digest         = optional(string)<br>    digest_type    = optional(number)<br>    fingerprint    = optional(string)<br>    flags          = optional(string)<br>    key_tag        = optional(number)<br>    lat_degrees    = optional(number)<br>    lat_direction  = optional(string)<br>    lat_minutes    = optional(number)<br>    lat_seconds    = optional(number)<br>    long_degrees   = optional(number)<br>    long_direction = optional(string)<br>    long_minutes   = optional(number)<br>    long_seconds   = optional(number)<br>    matching_type  = optional(number)<br>    name           = optional(string)<br>    order          = optional(number)<br>    port           = optional(number)<br>    precision_horz = optional(number)<br>    precision_vert = optional(number)<br>    preference     = optional(number)<br>    priority       = optional(number)<br>    proto          = optional(string)<br>    protocol       = optional(number)<br>    public_key     = optional(string)<br>    regex          = optional(string)<br>    replacement    = optional(string)<br>    selector       = optional(number)<br>    service        = optional(string)<br>    size           = optional(number)<br>    tag            = optional(string)<br>    target         = optional(string)<br>    type           = optional(number)<br>    usage          = optional(number)<br>    value          = optional(string)<br>    weight         = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name to which we will add the record. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the record. | `string` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | The priority of the record. Default value is `1`. | `number` | `1` | no |
| <a name="input_proxied"></a> [proxied](#input\_proxied) | Set the record to gets Cloudflare's origin protection | `bool` | `false` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | The TTL of the record. Default value is `1`. | `number` | `1` | no |
| <a name="input_type"></a> [type](#input\_type) | The type of the record. | `string` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | The value of the record. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_record_created_on"></a> [record\_created\_on](#output\_record\_created\_on) | The RFC3339 timestamp of when record was created. |
| <a name="output_record_hostnames"></a> [record\_hostnames](#output\_record\_hostnames) | The FQDN of the record. |
| <a name="output_record_ids"></a> [record\_ids](#output\_record\_ids) | The record ID. |
| <a name="output_record_metadata"></a> [record\_metadata](#output\_record\_metadata) | A key-value map of string metadata Cloudflare associates with a record. |
| <a name="output_record_modified_on"></a> [record\_modified\_on](#output\_record\_modified\_on) | The RFC3339 timestamp of when record were last modified. |
| <a name="output_record_proxiable"></a> [record\_proxiable](#output\_record\_proxiable) | Show record is proxied. |

<!-- END_TF_DOCS -->


<!-- references -->

[repo_link]: https://github.com/Infrastrukturait/terraform-cloudflare-zone
