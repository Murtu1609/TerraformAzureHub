


resource "azurerm_subnet" "bastionsub" {
  for_each = var.bastion ? toset(["1"]) : []

  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  name             = "AzureBastionSubnet"
  address_prefixes = [var.bastionsubnetaddress]
}

resource "azurerm_public_ip" "bpip" {
  for_each = var.bastion ? toset(["1"]) : []

  name                = "bastionpip"
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion ? toset(["1"]) : []

  name                = "bastion"
  location            = var.resourcegrouplocation
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags

  ip_configuration {
    name                 = "bastion"
    subnet_id            = azurerm_subnet.bastionsub[1].id
    public_ip_address_id = azurerm_public_ip.bpip[1].id
  }
}

