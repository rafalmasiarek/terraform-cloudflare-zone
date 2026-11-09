terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 5.28.1, < 6.0.0"
    }
    # Not yet published to the registry - requires dev_overrides pointing
    # at a local build until a release exists. See
    # https://github.com/rafalmasiarek/terraform-provider-netutils.
    netutils = {
      source = "rafalmasiarek/netutils"
    }
  }

  required_version = ">= 1.9.0"
}
