output "zone_id" {
  value       = cloudflare_zone.this.id
  description = "The zone ID."
}

output "meta" {
  value       = cloudflare_zone.this.meta
  description = "Map of booleans, indicating some zone statuses or flags."
}

output "name_servers" {
  value       = cloudflare_zone.this.name_servers
  description = "Cloudflare-assigned name servers. This is only populated for zones that use Cloudflare DNS."
}

output "status" {
  value       = cloudflare_zone.this.status
  description = "Status of the zone. Valid values: active, pending, initializing, moved."
}

output "vanity_name_servers" {
  value       = cloudflare_zone.this.vanity_name_servers
  description = "List of Vanity Nameservers, if set."
}

output "verification_key" {
  value       = cloudflare_zone.this.verification_key
  description = "Contains the TXT record value to validate domain ownership. This is only populated for zones of type partial."
}

output "dnssec_status" {
  value       = try(cloudflare_zone_dnssec.this[0].status, null)
  description = "The status of the Zone DNSSEC."
}

output "flags" {
  value       = try(cloudflare_zone_dnssec.this[0].flags, null)
  description = "Zone DNSSEC flags."
}

output "algorithm" {
  value       = try(cloudflare_zone_dnssec.this[0].algorithm, null)
  description = "Zone DNSSEC algorithm."
}

output "key_type" {
  value       = try(cloudflare_zone_dnssec.this[0].key_type, null)
  description = "Key type used for Zone DNSSEC."
}

output "digest_type" {
  value       = try(cloudflare_zone_dnssec.this[0].digest_type, null)
  description = "Digest Type for the Zone DNSSEC."
}

output "digest_algorithm" {
  value       = try(cloudflare_zone_dnssec.this[0].digest_algorithm, null)
  description = "Digest algorithm used for Zone DNSSEC."
}

output "digest" {
  value       = try(cloudflare_zone_dnssec.this[0].digest, null)
  description = "Zone DNSSEC digest."
}

output "ds" {
  value       = try(cloudflare_zone_dnssec.this[0].ds, null)
  description = "DS for the Zone DNSSEC."
}

output "key_tag" {
  value       = try(cloudflare_zone_dnssec.this[0].key_tag, null)
  description = "Key Tag for the Zone DNSSEC."
}

output "public_key" {
  value       = try(cloudflare_zone_dnssec.this[0].public_key, null)
  description = "Public Key for the Zone DNSSEC."
}

output "modified_on" {
  value       = try(cloudflare_zone_dnssec.this[0].modified_on, null)
  description = "Zone DNSSEC updated time."
}

output "record_ids" {
  value       = { for k, v in cloudflare_dns_record.this : k => v.id }
  description = "The record IDs keyed by the module's managed record key."
}

output "record_names" {
  value       = { for k, v in cloudflare_dns_record.this : k => v.name }
  description = "The managed DNS record names keyed by the module's managed record key."
}

output "record_proxiable" {
  value       = { for k, v in cloudflare_dns_record.this : k => v.proxiable }
  description = "Shows whether these records can be proxied. This must be true if setting proxied = true."
}

output "record_modified_on" {
  value       = { for k, v in cloudflare_dns_record.this : k => v.modified_on }
  description = "The RFC3339 timestamp of when the records were last modified."
}

output "zone_hold_status" {
  value       = try(cloudflare_zone_hold.this[0].hold, null)
  description = "Whether a Zone Hold is currently active, if zone_hold was declared."
}

output "zone_lockdown_ids" {
  value       = { for k, v in cloudflare_zone_lockdown.this : k => v.id }
  description = "The Zone Lockdown rule IDs keyed by the module's zone_lockdowns key."
}

output "page_rule_ids" {
  value       = { for k, v in cloudflare_page_rule.this : k => v.id }
  description = "The Page Rule IDs keyed by the module's page_rules key."
}

output "hostname_tls_setting_ids" {
  value = {
    ciphers         = { for k, v in cloudflare_hostname_tls_setting.ciphers : k => v.id }
    min_tls_version = { for k, v in cloudflare_hostname_tls_setting.min_tls_version : k => v.id }
    http2           = { for k, v in cloudflare_hostname_tls_setting.http2 : k => v.id }
  }
  description = "The hostname TLS setting IDs, keyed by setting_id then hostname."
}

output "workers_route_ids" {
  value       = { for k, v in cloudflare_workers_route.this : k => v.id }
  description = "The Workers Route IDs keyed by the route pattern."
}

output "worker_hostname_ids" {
  value       = { for k, v in cloudflare_workers_custom_domain.this : k => v.id }
  description = "The Workers Custom Domain IDs keyed by hostname."
}
