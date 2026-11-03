module "zone" {
  source = "../.."

  zone       = var.zone
  account_id = var.account_id

  comment = "Managed by Terraform"

  records = [
    {
      record_name = "bastion-example-a"
      name        = "bastion-example"
      value       = "1.1.1.1"
      type        = "A"
      ttl         = 1
    },
    {
      record_name = "api-example-a"
      name        = "api-example"
      value       = "1.1.1.1"
      type        = "A"
      ttl         = 1
    }
  ]

  mx = {
    names = ["@"]
    servers = [
      {
        host     = "mx1.mail.example.net"
        priority = 10
      },
      {
        host     = "mx2.mail.example.net"
        priority = 20
      }
    ]
    ttl = 3600
  }

  spf = {
    includes = ["_spf.google.com", "spf.mailgun.org"]
    ip4s     = ["192.0.2.10"]
    all      = "softfail"
    ttl      = 3600
  }

  dmarc = {
    policy    = "quarantine"
    rua       = ["mailto:dmarc@example.com"]
    spf_mode  = "relaxed"
    dkim_mode = "relaxed"
    percent   = 100
    ttl       = 3600
  }

  tlsrpt = {
    rua = ["mailto:tlsrpt@example.com"]
    ttl = 3600
  }

  dkim = {
    selector1 = {
      type       = "TXT"
      public_key = "REPLACE_WITH_YOUR_DKIM_PUBLIC_KEY"
      ttl        = 3600
    }

    google = {
      type   = "CNAME"
      target = "google._domainkey.mail.provider.example.net"
      ttl    = 3600
    }
  }

  zone_settings = [
    {
      setting_id = "always_use_https"
      enabled    = true
    }
  ]

  rulesets = [
    {
      key   = "zone-http-config"
      name  = "Zone HTTP configuration"
      kind  = "zone"
      phase = "http_request_dynamic_redirect"

      rules = [
        {
          ref         = "redirect-http-to-https"
          description = "Redirect all HTTP requests to HTTPS"
          action      = "redirect"
          expression  = "(http.request.scheme eq \"http\")"
          enabled     = true

          action_parameters = {
            from_value = {
              status_code           = 301
              preserve_query_string = true

              target_url = {
                expression = "concat(\"https://\", http.host, http.request.uri.path)"
              }
            }
          }
        }
      ]
    }
  ]

  lists = [
    {
      key  = "example-net"
      kind = "ip"
      name = "example-net"
      items = [
        { ip = "192.0.2.1", comment = "TEST-NET-1 example" }
      ]
    }
  ]
}
