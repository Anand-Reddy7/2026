data "ibm_resource_group" "main" {
  name = var.resource_group
}

data "ibm_is_image" "image" {
  name = var.image
}

data "ibm_is_ssh_key" "key" {
  name = var.ssh_key
}