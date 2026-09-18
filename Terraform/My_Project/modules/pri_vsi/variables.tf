variable "prefix" {
  type    = string
  default = "anand"
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "pri_server_count" {
  type = number
}

variable "image" {
  type = string
}

variable "profile" {
  type = string
}

variable "keys" {
  type = list(string)
}

variable "pri_subnet_id" {
  type = string
}

variable "pri_sg" {
  type = string
}