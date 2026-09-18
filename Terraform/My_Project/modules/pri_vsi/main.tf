resource "ibm_is_instance" "pri_vsi" {
  count          = var.pri_server_count
  name           = "${var.prefix}-pri-vsi-${count.index + 1}"
  resource_group = var.resource_group_id

  vpc  = var.vpc_id
  zone = "${var.region}-2"

  image   = var.image
  profile = var.profile

  keys = var.keys

  primary_network_interface {
    name   = "eth0"
    subnet = var.pri_subnet_id

    security_groups = [var.pri_sg]
  }
}