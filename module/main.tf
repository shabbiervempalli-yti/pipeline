# refer to a resource group
data "azurerm_resource_group" "resourcegroup" {
  name = var.resourcegroup
}

#refer to a subnet
data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = data.azurerm_resource_group.resourcegroup.name
}
resource "azurerm_network_interface" "nic" {
  for_each            =  toset(var.vm_name)
  name                = each.value
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  location            = data.azurerm_resource_group.resourcegroup.location
  ip_configuration {
    name              = "internal"
    subnet_id         = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            =  toset(var.vm_name)
  name                            = each.value
  resource_group_name             = data.azurerm_resource_group.resourcegroup.name
  location                        = data.azurerm_resource_group.resourcegroup.location
  size                            = var.vmsize
  admin_username                  = var.username
  admin_password                  = var.password
  #disable_password_authentication = false
  zone = var.zone
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
    #azurerm_network_interface.internal[each.key].id,
  ]
  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name    ="${each.key}-osdisk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb = var.osdisk
  }
}
resource "azurerm_managed_disk" "disk" {
  for_each            =  toset(var.vm_name)
  name                 = each.value
  location             = data.azurerm_resource_group.resourcegroup.location
  resource_group_name  = data.azurerm_resource_group.resourcegroup.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disksize
  zones = var.zones
  depends_on = [ azurerm_linux_virtual_machine.vm ]
}
resource "azurerm_virtual_machine_data_disk_attachment" "disk-attach" {
  for_each            =  toset(var.vm_name)
  managed_disk_id    =  azurerm_managed_disk.disk[each.key].id
  virtual_machine_id =  azurerm_linux_virtual_machine.vm[each.key].id
  lun                = "10"
  caching            = "ReadWrite"
  depends_on = [ azurerm_managed_disk.disk ]
}
resource "azurerm_virtual_machine_extension" "extensions" {
  for_each            =  toset(var.vm_name)
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${filebase64("mount.sh")}"
    }
SETTINGS
}
