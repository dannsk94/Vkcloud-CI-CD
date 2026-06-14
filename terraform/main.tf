terraform {
  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = "~> 0.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "s3" {
    bucket   = "terraform-state-lab2-m05"
    key      = "lab2/terraform.tfstate"
    region   = "ru-msk"
    endpoints = {
      s3 = "https://hb.ru-msk.vkcloud-storage.ru"
    }
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "vkcs" {
  auth_url          = var.auth_url
  user_domain_name  = var.user_domain_name
  project_id        = var.project_id
  username          = var.username
  password          = var.password
}