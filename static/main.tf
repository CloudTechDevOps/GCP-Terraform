terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "playground-s-11-fadf1fbb"
  region  = "us-central1"
}

# Create bucket for website hosting
resource "google_storage_bucket" "website" {
  name          = "gcp-staticwebsite-hosting-narehit"
  location      = "US"
  force_destroy = true

  # Do NOT set uniform_bucket_level_access = true
  # This avoids IAM calls that fail in lab

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Upload local files (edit the ./site folder)
locals {
  site_files = fileset("./site", "**")
}

resource "google_storage_bucket_object" "files" {
  for_each = local.site_files
  name     = each.value
  bucket   = google_storage_bucket.website.name
  source   = "./site/${each.value}"

  # Do NOT set predefined_acl = "publicRead"
  # Lab users cannot modify ACLs either
}

# Output endpoint
output "website_endpoint" {
  description = "URL to access the website (may be private in lab)"
  value       = "http://${google_storage_bucket.website.name}.storage.googleapis.com/index.html"
}
