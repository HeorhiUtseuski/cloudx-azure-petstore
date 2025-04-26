variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type = string
  default = "Standard"
}

variable "admin_enabled" {
  type = bool
  default = false
}

variable "key_vault_id" {
  type = string
}

variable "user_assigned_id" {
  type = string
}

variable "user_assigned_principal_id" {
  type = string
}