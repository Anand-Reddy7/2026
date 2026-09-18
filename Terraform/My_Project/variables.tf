variable "prefix" {
  type    = string
  default = "anand"

  validation {
    condition     = var.prefix != null && trimspace(var.prefix) != ""
    error_message = "Prefix value should not be null, empty, or whitespace."
  }
}

variable "region" {
  type = string
}

variable "ibmcloud_api_key" {
  type      = string
  sensitive = true
}

variable "resource_group" {
  type    = string
  default = "HPCC"
}

variable "image" {
  type    = string
  default = "ibm-redhat-9-8-minimal-amd64-3"
}

variable "profile" {
  type    = string
  default = "bx2-2x8"
}

variable "ssh_key" {
  type = string
}

variable "pub_server_count" {
  type    = number
  default = 1

  validation {
    condition     = var.pub_server_count >= 1
    error_message = "The Public Server count always grater than 1"
  }
}

variable "pri_server_count" {
  type    = number
  default = 2
}