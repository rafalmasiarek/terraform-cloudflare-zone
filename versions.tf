terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 5.28.1, < 6.0.0"
    }
  }

  required_version = ">= 1.5.0"
}
