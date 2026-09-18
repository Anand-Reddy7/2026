resource "ibm_is_instance" "pub_vsi" {
  count          = var.pub_server_count
  name           = "${var.prefix}-pub-vsi-${count.index + 1}"
  resource_group = var.resource_group_id

  vpc  = var.vpc_id
  zone = "${var.region}-1"

  image   = var.image
  profile = var.profile

  keys = var.keys

  primary_network_interface {
    name   = "eth0"
    subnet = var.pub_subnet_id

    security_groups = [var.pub_sg]
  }

  # User Data
  user_data = <<-EOF
        #!/bin/bash

        sudo yum install ansible-core -y
        sudo ansible --version
    EOF

#   lifecycle {
#     ignore_changes = [
#       user_data
#     ]
#   }
}

## Create FIP
resource "ibm_is_floating_ip" "fip" {
  count          = var.pub_server_count
  name           = "${var.prefix}-fip-${count.index + 1}"
  resource_group = var.resource_group_id
  target         = ibm_is_instance.pub_vsi[count.index].primary_network_interface[0].id
  depends_on     = [ibm_is_instance.pub_vsi]
}