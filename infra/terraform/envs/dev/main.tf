terraform {
  required_version = ">= 1.7.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# CLOUDFLARE_API_TOKEN must be exported in the runner's environment.
provider "cloudflare" {}

variable "account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "project_name" {
  type        = string
  description = "Cloudflare Pages project name."
}

variable "production_branch" {
  type        = string
  default     = "main"
  description = "Branch that Cloudflare Pages treats as production."
}

variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID for action-atoms.com"
  default     = "a3b1d66afeb88714338d43942c3a825a"
}

# Replace with the real GitHub repo coordinates during bootstrap.
resource "cloudflare_pages_project" "site" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch

  build_config {
    build_command   = "npm run build"
    destination_dir = "dist"
    root_dir        = "web"
  }
}

resource "cloudflare_record" "apex" {
  zone_id = var.zone_id
  name    = "@"
  content = cloudflare_pages_project.site.subdomain
  type    = "CNAME"
  proxied = true
  ttl     = 1
  comment = "Apex CNAME → CF Pages project (auto-flattened by CF)"
}

output "subdomain" {
  value       = cloudflare_pages_project.site.subdomain
  description = "Default *.pages.dev hostname for the project."
}
