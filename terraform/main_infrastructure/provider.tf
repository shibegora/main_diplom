terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.8.4"

  backend "s3" {
    endpoints = {
    s3 = "https://storage.yandexcloud.net"
  }
  bucket                      = "terraform-state-shibegora-bucket"
  key                         = "main-infra/terraform.tfstate"
  region                      = "ru-central1"
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_s3_checksum            = true
  }
}

provider "yandex" {
  service_account_key_file      = "${path.module}/key.json"
  cloud_id                      = var.cloud_id
  folder_id                     = var.folder_id
}