variable "name" {
  type = string
}

variable "context_path" {
  type = string
}

variable "container_registry_name" {
  type = string
}

variable "container_registry_login_server" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "image_tag" {
  type = string
  default = "latest"
}

variable "admin_username_secret_name" {
  type = string
}

variable "admin_password_secret_name" {
  type = string
}