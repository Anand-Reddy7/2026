terraform {
  required_version = ">=1.5.0"

  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }

    local = {
      source = "hashicorp/local"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://s3.jp-tok.cloud-object-storage.appdomain.cloud"
    }
    bucket = "anand-backend"
    key    = "dev/terraform.tfstate"
    region = "jp-tok"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true

    use_path_style = true
    use_lockfile   = true
  }
}

provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

# // Varibales

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

variable "private_server_count" {
  type    = number
  default = 2
}


# // Data Block

data "ibm_resource_group" "main" {
  name = var.resource_group
}

data "ibm_is_image" "image" {
  name = var.image
}

data "ibm_is_ssh_key" "key" {
  name = var.ssh_key
}

# // Locals

locals {
  resource_group_id = data.ibm_resource_group.main.id
}

# // Create a VPC
resource "ibm_is_vpc" "main" {
  name                      = "${var.prefix}-vpc"
  resource_group            = local.resource_group_id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "main-pub-prefix" {
  name = "${var.prefix}-vpc-pub-address-prefix"
  vpc  = ibm_is_vpc.main.id
  zone = "${var.region}-1"
  cidr = "10.20.0.0/21"
}

resource "ibm_is_vpc_address_prefix" "main-pri-prefix" {
  name = "${var.prefix}-vpc-pri-address-prefix"
  vpc  = ibm_is_vpc.main.id
  zone = "${var.region}-2"
  cidr = "10.20.32.0/19"
}

## // Create Public Gateway

resource "ibm_is_public_gateway" "pub_gateway" {
  name           = "${var.prefix}-pg"
  vpc            = ibm_is_vpc.main.id
  zone           = "${var.region}-1"
  resource_group = local.resource_group_id
}


## // Subnets
resource "ibm_is_subnet" "pub_subnet" {
  name           = "${var.prefix}-pub-subnet"
  resource_group = local.resource_group_id

  vpc             = ibm_is_vpc.main.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.20.0.0/21"

  public_gateway = ibm_is_public_gateway.pub_gateway.id

  depends_on = [ibm_is_vpc_address_prefix.main-pub-prefix]
}


resource "ibm_is_subnet" "pri_subnet" {
  name           = "${var.prefix}-pri-subnet"
  resource_group = local.resource_group_id

  vpc             = ibm_is_vpc.main.id
  zone            = "${var.region}-2"
  ipv4_cidr_block = "10.20.32.0/19"

  depends_on = [ibm_is_vpc_address_prefix.main-pri-prefix]
}

## // Security Groups

resource "ibm_is_security_group" "pub_sg" {
  name = "${var.prefix}-pub-sg"

  vpc            = ibm_is_vpc.main.id
  resource_group = local.resource_group_id
}

resource "ibm_is_security_group" "pri_sg" {
  name = "${var.prefix}-pri-sg"

  vpc            = ibm_is_vpc.main.id
  resource_group = local.resource_group_id
}

## // Security Group Rules

## // Pub
resource "ibm_is_security_group_rule" "pub-sg-rule-ssh" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "inbound"
  remote    = "49.37.161.23/32"
  protocol  = "tcp"
  port_min  = 22
  port_max  = 22
}

resource "ibm_is_security_group_rule" "pub-sg-rule-jump" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "inbound"
  remote    = "162.133.135.229/32"
  protocol  = "tcp"
  port_min  = 22
  port_max  = 22
}

resource "ibm_is_security_group_rule" "pub-sg-http" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "inbound"
  remote    = "49.37.161.23/32"
  protocol  = "tcp"
  port_min  = 80
  port_max  = 80
}

resource "ibm_is_security_group_rule" "pub_outbound" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

## // Pri
resource "ibm_is_security_group_rule" "pri_from_pub_sg" {
  group     = ibm_is_security_group.pri_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.pub_sg.id
}

resource "ibm_is_security_group_rule" "pri_outbound" {
  group     = ibm_is_security_group.pri_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

## Create a Pub_VSI

resource "ibm_is_instance" "pub_vsi" {
  count          = var.pub_server_count
  name           = "${var.prefix}-pub-vsi-${count.index + 1}"
  resource_group = local.resource_group_id

  vpc  = ibm_is_vpc.main.id
  zone = "${var.region}-1"

  image   = data.ibm_is_image.image.id
  profile = var.profile

  keys = [data.ibm_is_ssh_key.key.id]

  primary_network_interface {
    name   = "eth0"
    subnet = ibm_is_subnet.pub_subnet.id

    security_groups = [ibm_is_security_group.pub_sg.id]
  }

  # User Data
  user_data = <<-EOF
        #!/bin/bash

        sudo yum install ansible-core -y
        sudo ansible --version
    EOF

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }
}

## // create FIP
resource "ibm_is_floating_ip" "fip" {
  count          = var.pub_server_count
  name           = "${var.prefix}-fip-${count.index + 1}"
  resource_group = local.resource_group_id
  target         = ibm_is_instance.pub_vsi[count.index].primary_network_interface[0].id
  depends_on     = [ibm_is_instance.pub_vsi]
}


## // Create a Private VSI

resource "ibm_is_instance" "pri_vsi" {
  count          = var.private_server_count
  name           = "${var.prefix}-pri-vsi-${count.index + 1}"
  resource_group = local.resource_group_id

  vpc  = ibm_is_vpc.main.id
  zone = "${var.region}-2"

  profile = var.profile
  image   = data.ibm_is_image.image.id
  keys    = [data.ibm_is_ssh_key.key.id]

  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.pri_subnet.id
    security_groups = [ibm_is_security_group.pri_sg.id]
  }
}


/*
##  // Connect to the Public VSI server and Do nessasary operations

resource "null_resource" "config_pub_vsi" {
    depends_on = [ibm_is_instance.pub_vsi, ibm_is_floating_ip.fip]

    triggers = {
        file_hash = filesha256("${path.module}/main.tf")
    }

    connection {
        type = "ssh"
        host = ibm_is_floating_ip.fip.address
        user = "vpcuser"
        private_key = file("/root/id_rsa")
    }

    provisioner "local-exec" {
        command = "echo Server Name: ${ibm_is_instance.pub_vsi.name}"
    }

    provisioner "file" {
        source = "main.tf.bak"
        destination = "/tmp/main.tf"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install nginx -y",
            "echo 'Hello Anand' | sudo tee /usr/share/nginx/html/index.html",
            "sudo service nginx enable",
            "sudo service nginx start"
        ]
    }
}

## // Private server with bastion

resource "null_resource" "conn_to_pri_insta" {
    depends_on = [
        ibm_is_instance.pub_vsi,
        ibm_is_floating_ip.fip,
        ibm_is_instance.pri_vsi
    ]

    connection {
        type = "ssh"

        # bastion
        host = ibm_is_instance.pri_vsi.primary_network_interface[0].primary_ip[0].address
        user = "vpcuser"
        private_key = file("/root/id_rsa")

        # Private server
        bastion_host = ibm_is_floating_ip.fip.address
        bastion_user = "vpcuser"
        bastion_private_key = file("/root/id_rsa")

    }

    provisioner "remote-exec" {
    inline = [
        "sudo yum install nginx -y",
        "echo 'Hello Anand - Private Server' | sudo tee /usr/share/nginx/html/index.html",
        "sudo systemctl enable --now nginx",
        "sudo systemctl start nginx"
        ]
    }
}
*/

## // Creating the .ini file

resource "local_file" "ansible_ini_Creation" {
  depends_on = [
    ibm_is_instance.pub_vsi,
    ibm_is_instance.pri_vsi,
    ibm_is_floating_ip.fip
  ]

  filename = "${path.module}/inventory.ini"

  content = <<-EOF
    [public_servers]
    ${join("\n", [for vsi in ibm_is_floating_ip.fip : vsi.address])}

    [private_servers]
    ${join("\n", [
  for vsi in ibm_is_instance.pri_vsi :
  vsi.primary_network_interface[0].primary_ip[0].address
])}

    [all:vars]
    ansible_user=vpcuser
    ansible_ssh_private_key_file=/root/id_rsa

    [private_servers:vars]
    ansible_ssh_common_args='-o ProxyCommand="ssh -i /root/id_rsa -o StrictHostKeyChecking=no -W %h:%p vpcuser@${ibm_is_floating_ip.fip[0].address}" -o StrictHostKeyChecking=no'
  EOF
}

## //Null Resource to trigger the Ansible 

resource "null_resource" "ansible_playbook" {
  depends_on = [
    local_file.ansible_ini_Creation
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sudo ansible-playbook -i /root/Anand/inventory.ini nginx.yml -e 'target_group=public_servers'"
  }
}


## Output
output "vpc_id" {
  value = ibm_is_vpc.main.id
}

output "vsi_fips" {
  value = [
    for fip in ibm_is_floating_ip.fip :
    fip.address
  ]
}

/*
output "pri_vsi_fip" {
    value = ibm_is_instance.pri_vsi.primary_network_interface[0].primary_ip[0].address
}
*/

output "pri_vsi_ips" {
  value = [
    for vsi in ibm_is_instance.pri_vsi :
    vsi.primary_network_interface[0].primary_ip[0].address
  ]
}