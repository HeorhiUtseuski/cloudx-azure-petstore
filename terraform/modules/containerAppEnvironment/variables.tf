variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "logs_destination" {
  type = string
  default = "log-analytics"
}

variable "log_analytics_workspace_id" {
  type = string
}