

resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroupname
  location = var.resourcegrouplocation
  tags     = var.tags 
}

resource "azurerm_virtual_network" "vnet" {
  name                = azurerm_resource_group.rg.name
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.addressspace
  location            = var.resourcegrouplocation
  tags                = azurerm_resource_group.rg.tags

}

resource "azurerm_network_security_group" "nsg" {
  for_each            = toset(var.subnets.*.sg)
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = toset(var.subnets.*.name)

  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  name             = each.value
  address_prefixes = [var.subnets[index(var.subnets.*.name, each.value)].address]

}


resource "azurerm_subnet_network_security_group_association" "subnetnsg" {
  for_each = {
    for sub in var.subnets :
    sub.name => sub.sg
  }
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value].id
}

locals {
  rules = csvdecode(file(var.sgrulespath))
}


resource "azurerm_network_security_rule" "sgrules" {

  depends_on = [
    azurerm_network_security_group.nsg,
  ]

  for_each = toset(local.rules.*.name)

  name                        = each.key
  priority                    = local.rules[index(local.rules.*.name, each.key)].priority
  direction                   = local.rules[index(local.rules.*.name, each.key)].direction
  access                      = local.rules[index(local.rules.*.name, each.key)].access
  protocol                    = local.rules[index(local.rules.*.name, each.key)].protocol
  source_port_range           = local.rules[index(local.rules.*.name, each.key)].sourceport
  destination_port_range      = local.rules[index(local.rules.*.name, each.key)].destinationport
  source_address_prefix       = local.rules[index(local.rules.*.name, each.key)].sourceaddress != "na" ? local.rules[index(local.rules.*.name, each.key)].sourceaddress : null
  destination_address_prefix  = local.rules[index(local.rules.*.name, each.key)].destaddress != "na" ? local.rules[index(local.rules.*.name, each.key)].destaddress : null
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = local.rules[index(local.rules.*.name, each.key)].nsg


  source_application_security_group_ids      = local.rules[index(local.rules.*.name, each.key)].sourceasg != "na" ? [azurerm_application_security_group.asgs[local.rules[index(local.rules.*.name, each.key)].sourceasg].id] : null
  destination_application_security_group_ids = local.rules[index(local.rules.*.name, each.key)].destasg != "na" ? [azurerm_application_security_group.asgs[local.rules[index(local.rules.*.name, each.key)].destasg].id] : null

  #source_application_security_group_ids = local.rules[index(local.rules.*.name, each.key)].sourceasg !="na" ? [for r in split(";",local.rules[index(local.rules.*.name,each.key)].sourceasg):azurerm_application_security_group.asgs[r].id] :null
  #destination_application_security_group_ids = local.rules[index(local.rules.*.name, each.key)].destasg !="na" ? [for r in split(";",local.rules[index(local.rules.*.name,each.key)].destasg):azurerm_application_security_group.asgs[r].id] :null

  source_address_prefixes      = local.rules[index(local.rules.*.name, each.key)].sourceaddresses != "na" ? [for r in split(";", local.rules[index(local.rules.*.name, each.key)].sourceaddresses) : r] : null
  destination_address_prefixes = local.rules[index(local.rules.*.name, each.key)].destaddresses != "na" ? [for r in split(";", local.rules[index(local.rules.*.name, each.key)].destaddresses) : r] : null

}



