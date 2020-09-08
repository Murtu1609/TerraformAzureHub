


resource "azurerm_availability_set" "avset" {
  for_each = toset(concat(local.linuxvm.*.avset, local.vm.*.avset))

  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_application_security_group" "asgs" {
  for_each            = toset(var.asgs.*)
  name                = each.value
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation
  name                = "${var.resourcegroupname}-${random_string.rstring.result}"
  tags                = azurerm_resource_group.rg.tags
}

locals {
  #vm = csvdecode(file("${path.module}/windowsvms.csv"))
  vm = csvdecode(file(var.windowsvmpath))
}

data "azurerm_image" "im" {
  for_each            = toset(local.vm.*.imagename)
  name                = each.key
  resource_group_name = local.vm[index(local.vm.*.imagename, each.key)].imagerg
}


resource "azurerm_network_interface" "nic" {
  for_each            = toset(local.vm.*.name)
  name                = each.key
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags

  ip_configuration {
    name                          = each.key
    private_ip_address_allocation = local.vm[index(local.vm.*.name, each.key)].ipalloc
    private_ip_address            = local.vm[index(local.vm.*.name, each.key)].ipalloc == "static" ? local.vm[index(local.vm.*.name, each.key)].ip : null
    subnet_id                     = azurerm_subnet.subnet[local.vm[index(local.vm.*.name, each.key)].subnet].id
  }
}

resource "azurerm_network_interface_application_security_group_association" "winnicasg1" {
  for_each = {
    for vm in local.vm :
    vm.name => vm.asg
    if vm.asg != "na"
  }
  network_interface_id          = azurerm_network_interface.nic[each.key].id
  application_security_group_id = azurerm_application_security_group.asgs[each.value].id
}

resource "azurerm_network_interface_application_security_group_association" "winnicasg2" {
  for_each = {
    for vm in local.vm :
    vm.name => vm.asg2
    if vm.asg2 != "na"
  }
  network_interface_id          = azurerm_network_interface.nic[each.key].id
  application_security_group_id = azurerm_application_security_group.asgs[each.value].id

}

resource "azurerm_network_interface_application_security_group_association" "winnicasg3" {
  for_each = {
    for vm in local.vm :
    vm.name => vm.asg3
    if vm.asg3 != "na"
  }
  network_interface_id          = azurerm_network_interface.nic[each.key].id
  application_security_group_id = azurerm_application_security_group.asgs[each.value].id

}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each = toset(local.vm.*.name)

  name                = each.key
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name

  admin_password        = azurerm_key_vault_secret.windowspwd.value
  admin_username        = local.vm[index(local.vm.*.name, each.key)].adminuser
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  source_image_id       = data.azurerm_image.im[local.vm[index(local.vm.*.name, each.key)].imagename].id
  size                  = local.vm[index(local.vm.*.name, each.key)].size
  availability_set_id   = azurerm_availability_set.avset[local.vm[index(local.vm.*.name, each.key)].avset].id
  tags                  = azurerm_resource_group.rg.tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
  }
}


resource "azurerm_backup_protected_vm" "wvm" {
  for_each            = var.recoveryvault ? toset(local.vm.*.name) : []
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.recvault[1].name
  source_vm_id        = azurerm_windows_virtual_machine.vm[each.value].id
  backup_policy_id    = azurerm_backup_policy_vm.bp[1].id
}


#========================================================================================================

locals {
  #linuxvm = csvdecode(file("${path.module}/linuxvms.csv"))
  linuxvm = csvdecode(file(var.linuxvmpath))
}

data "azurerm_image" "lim" {
  for_each            = toset(local.linuxvm.*.imagename)
  name                = each.key
  resource_group_name = local.linuxvm[index(local.linuxvm.*.imagename, each.key)].imagerg
}

resource "azurerm_network_interface" "lnic" {
  for_each            = toset(local.linuxvm.*.name)
  name                = each.key
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags

  ip_configuration {
    name                          = each.key
    private_ip_address_allocation = local.linuxvm[index(local.linuxvm.*.name, each.key)].ipalloc
    private_ip_address            = local.linuxvm[index(local.linuxvm.*.name, each.key)].ipalloc == "static" ? local.linuxvm[index(local.linuxvm.*.name, each.key)].ip : null
    subnet_id                     = azurerm_subnet.subnet[local.linuxvm[index(local.linuxvm.*.name, each.key)].subnet].id
  }
}

resource "azurerm_network_interface_application_security_group_association" "linnicasg1" {
  for_each = {
    for vm in local.linuxvm :
    vm.name => vm.asg
    if vm.asg != "na"
  }
  network_interface_id          = azurerm_network_interface.lnic[each.key].id
  application_security_group_id = azurerm_application_security_group.asgs[each.value].id
}

resource "azurerm_network_interface_application_security_group_association" "linnicasg2" {
  for_each = {
    for vm in local.linuxvm :
    vm.name => vm.asg2
    if vm.asg2 != "na"
  }
  network_interface_id          = azurerm_network_interface.lnic[each.key].id
  application_security_group_id = azurerm_application_security_group.asgs[each.value].id
}

resource "azurerm_network_interface_application_security_group_association" "linnicasg3" {
  for_each = {
    for vm in local.linuxvm :
    vm.name => vm.asg3
    if vm.asg3 != "na"
  }
  network_interface_id          = azurerm_network_interface.lnic[each.key].id
  application_security_group_id = azurerm_application_security_group.asgs[each.value].id
}


resource "azurerm_linux_virtual_machine" "linuxvm" {
  for_each = toset(local.linuxvm.*.name)

  name                = each.key
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name

  admin_username        = local.linuxvm[index(local.linuxvm.*.name, each.key)].adminuser
  network_interface_ids = [azurerm_network_interface.lnic[each.key].id]
  source_image_id       = data.azurerm_image.lim[local.linuxvm[index(local.linuxvm.*.name, each.key)].imagename].id
  size                  = local.linuxvm[index(local.linuxvm.*.name, each.key)].size
  availability_set_id   = azurerm_availability_set.avset[local.linuxvm[index(local.linuxvm.*.name, each.key)].avset].id
  tags                  = azurerm_resource_group.rg.tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }


  admin_ssh_key {
    username   = local.linuxvm[index(local.linuxvm.*.name, each.key)].adminuser
    public_key = azurerm_key_vault_secret.pubkey.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
  }

}


resource "azurerm_backup_protected_vm" "lvm" {
  for_each            = var.recoveryvault ? toset(local.linuxvm.*.name) : []
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.recvault[1].name
  source_vm_id        = azurerm_linux_virtual_machine.linuxvm[each.value].id
  backup_policy_id    = azurerm_backup_policy_vm.bp[1].id
}
