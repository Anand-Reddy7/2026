output "vsi_address" {
    value = [
        for fip in ibm_is_floating_ip.fip :
        fip.address
    ]
}