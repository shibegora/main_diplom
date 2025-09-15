variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "username" {
  default     = "shibegora-sa"
  description = "Yandex Cloud service account"
  type        = string
}

variable "iam_key_format" {
  default     = "PEM_FILE"
  description = "IAM key format for Terraform"
  type        = string
}

variable "editor_role" {
  default     = "editor"
  description = "Terraform-role"
  type        = string
}

variable "viewer_role" {
  default     = "viewer"
  description = "Terraform-role"
  type        = string
}

variable "storage_role" {
  default     = "storage.editor"
  description = "Terraform-role"
  type        = string
}

variable "bucket_name" {
  default     = "terraform-state-shibegora-bucket"
  description = "Bucket name"
  type        = string
}

variable "bucket_class" {
  default     = "STANDARD"
  description = "Bucket class"
  type        = string
}

variable "bucket_size" {
  default     = 1073741824
  description = "Bucket size"
  type        = number
}
variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}