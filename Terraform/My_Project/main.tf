# Create vpc
module "vpc" {
  source = "./modules/vpc"

  prefix            = var.prefix
  region            = var.region
  resource_group_id = local.resource_group_id
}

# Create SG's
module "security_groups" {
  source = "./modules/security_groups"

  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  resource_group_id = local.resource_group_id
}

module "pub_vsi" {
  source = "./modules/pub_vsi"

  region = var.region
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  resource_group_id = local.resource_group_id

  pub_server_count = var.pub_server_count
  image = data.ibm_is_image.image.id
  profile = var.profile
  keys = [data.ibm_is_ssh_key.key.id]
  pub_subnet_id = module.vpc.pub_subnet_id
  pub_sg = module.security_groups.pub_sg
}

module "pri_vsi" {
  source = "./modules/pri_vsi"

  region = var.region
  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  resource_group_id = local.resource_group_id

  pri_server_count = var.pri_server_count
  image = data.ibm_is_image.image.id
  profile = var.profile
  keys = [data.ibm_is_ssh_key.key.id]
  pri_subnet_id = module.vpc.pri_subnet_id
  pri_sg = module.security_groups.pri_sg
}


## Creating the .ini file

resource "local_file" "ansible_ini" {
  depends_on = [
    module.pub_vsi,
    module.pri_vsi
  ]

  filename = "${path.module}/inventory.ini"

  content = <<-EOF
    [public_servers]
    ${join("\n", module.pub_vsi.vsi_address)}

    [private_servers]
    ${join("\n", module.pri_vsi.vsi_address)}

    [all:vars]
    ansible_user=vpcuser
    ansible_ssh_private_key_file=/home/vpcuser/Final_Code/Terraform/id_rsa

  EOF
}

## //Null Resource to trigger the Ansible 

resource "null_resource" "ansible_playbook" {
  depends_on = [
    local_file.ansible_ini
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sudo ansible-playbook -i ./inventory.ini nginx.yml -e 'target_group=public_servers'"
  }
}
