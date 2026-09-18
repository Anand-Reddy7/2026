output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_gw_id" {
  value = module.vpc.public_gw_id
}

output "pub_subnet_id" {
  value = module.vpc.pub_subnet_id
}

output "pri_subnet_id" {
  value = module.vpc.pri_subnet_id
}

output "pub_sg" {
  value = module.security_groups.pub_sg
}

output "pri_sg" {
  value = module.security_groups.pri_sg
}

output "pub_vsi_ips" {
  value = module.pub_vsi.vsi_address
}

output "pri_vsi_ips" {
  value = module.pri_vsi.vsi_address
}