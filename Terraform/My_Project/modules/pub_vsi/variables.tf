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

variable "pub_server_count" {
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

variable "pub_subnet_id" {
  type = string
}

variable "pub_sg" {
  type = string
}