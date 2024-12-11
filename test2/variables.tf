variable "email_address" {
  type      = string
#  sensitive = true
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "management_group_parent" {
  type = string
}

variable "management_group_child" {
  type = set(string)
}

variable "resource_group_name" {
  type    = string
  default = "az104"
}

variable "subscription_id" {
  type      = string
#  sensitive = true
}

variable "tenant_id" {
  type      = string
#  sensitive = true
}
