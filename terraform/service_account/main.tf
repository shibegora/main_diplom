resource "yandex_iam_service_account" "terraform" {
  name        = var.username
}

resource "yandex_iam_service_account_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform.id
  format             = var.iam_key_format
}

resource "yandex_iam_service_account_static_access_key" "tf_sa_key" {
  service_account_id = yandex_iam_service_account.terraform.id
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-editor" {
  folder_id = var.folder_id
  role      = var.editor_role
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-viewer" {
  folder_id = var.folder_id
  role      = var.viewer_role
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform-storage" {
  folder_id = var.folder_id
  role      = var.storage_role
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

resource "yandex_storage_bucket" "terraform_state" {
  access_key = null
  secret_key = null
  folder_id  = var.folder_id
  bucket     = var.bucket_name
  max_size   = var.bucket_size
  default_storage_class = var.bucket_class
  anonymous_access_flags {
    read = false
    list = false
  }
}