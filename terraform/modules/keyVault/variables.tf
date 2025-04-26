variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku_name" {
  type = string
  default = "standard"
}

variable "purge_protection_enabled" {
  type = bool
  default = false
}

variable "soft_delete_retention_days" {
  type = number
  default = 7
}

variable "user_assigned_principal_id" {
  type = string
}