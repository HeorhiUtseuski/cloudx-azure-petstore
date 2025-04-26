variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "offer_type" {
  type = string
  default = "Standard"
}

variable "kind" {
  type = string
  default = "GlobalDocumentDB"
}

variable "consistency_level" {
  type = string
  default = "Session"
}

variable "user_assigned_id" {
  type = string
}
