output "vpc_id" {
    value = ibm_is_vpc.main.id
}

output "public_gw_id" {
    value = ibm_is_public_gateway.pub_gateway.id
}

output "pub_subnet_id" {
    value = ibm_is_subnet.pub_subnet.id
}

output "pri_subnet_id" {
    value = ibm_is_subnet.pri_subnet.id
}
