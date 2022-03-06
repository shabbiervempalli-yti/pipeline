output "db-IPs" {
  value = tomap({
    for name, vm in azurerm_network_interface.nic : name => vm.private_ip_address
  })
}
