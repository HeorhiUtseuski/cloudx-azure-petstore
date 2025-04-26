variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "container_registry_login_server" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "application_name" {
  type = string
}

variable "application_tag" {
  type = string
}

variable "enviroment_variables" {
  type = map(string)
  default = {}
}

variable "revision_mode" {
  type = string
  default = "Single"
}

variable "user_assigned_id" {
  type = string
}

variable "application_insights_connection_string_name" {
  type = string
}