output "vsi_address" {
    value = [
        for vsi in ibm_is_instance.pri_vsi : vsi.primary_network_interface[0].primary_ip[0].address
    ]
}