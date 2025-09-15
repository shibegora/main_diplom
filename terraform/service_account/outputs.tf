output "terraform_sa_id" {
  value = yandex_iam_service_account.terraform.id
}

output "terraform_sa_key_id" {
  value = yandex_iam_service_account_key.terraform_key.id
}

output "terraform_sa_key_created_at" {
  value = yandex_iam_service_account_key.terraform_key.created_at
}

output "terraform_sa_key_pem" {
  value     = yandex_iam_service_account_key.terraform_key.private_key
  sensitive = true
}

output "tf_s3_access_key" {
  value     = yandex_iam_service_account_static_access_key.tf_sa_key.access_key
  sensitive = true
}

output "tf_s3_secret_key" {
  value     = yandex_iam_service_account_static_access_key.tf_sa_key.secret_key
  sensitive = true
}