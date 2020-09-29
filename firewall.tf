
resource "azurerm_subnet" "fwsub" {
  for_each             = var.firewall ? toset(["1"]) : []
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.fwsubnet]

}

resource "azurerm_public_ip" "fwpip" {
  for_each            = var.firewall ? toset(["1"]) : []
  name                = "fwpip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation

  allocation_method = "Static"
  sku               = "standard"
  tags              = azurerm_resource_group.rg.tags
}

resource "azurerm_firewall" "fw" {
  for_each = var.firewall ? toset(["1"]) : []

  name                = "firewall"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation
  tags                = azurerm_resource_group.rg.tags

  ip_configuration {
    name                 = "fwIpConfig"
    public_ip_address_id = azurerm_public_ip.fwpip[1].id
    subnet_id            = azurerm_subnet.fwsub[1].id
  }
}


locals {
  fwnwrules = csvdecode(file(var.networkrulespath))
}


resource "azurerm_firewall_network_rule_collection" "fwnwrules" {
  for_each = var.firewall ? toset(local.fwnwrules.*.collectionname) : []

  name                = each.value
  azure_firewall_name = azurerm_firewall.fw[1].name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = local.fwnwrules[index(local.fwnwrules.*.collectionname, each.key)].priority
  action              = local.fwnwrules[index(local.fwnwrules.*.collectionname, each.key)].action

  dynamic rule {
    for_each = { for r in local.fwnwrules.*.rulename :
      r => each.key...
    if each.key == local.fwnwrules[index(local.fwnwrules.*.rulename, r)].collectionname }

    content {
      name                  = rule.key
      source_addresses      = [for s in split(";", local.fwnwrules[index(local.fwnwrules.*.rulename, rule.key)].sourceaddresses) : s]
      destination_addresses = [for d in split(";", local.fwnwrules[index(local.fwnwrules.*.rulename, rule.key)].destaddresses) : d]
      destination_ports     = [for d in split(";", local.fwnwrules[index(local.fwnwrules.*.rulename, rule.key)].destports) : d]
      protocols             = [for p in split(";", local.fwnwrules[index(local.fwnwrules.*.rulename, rule.key)].protocols) : p]
    }
  }
}

locals {
  fwnatrules = csvdecode(file(var.natrulespath))
}

resource "azurerm_firewall_nat_rule_collection" "fwnatrules" {
  for_each = var.firewall ? toset(local.fwnatrules.*.collectionname) : []

  name                = each.value
  azure_firewall_name = azurerm_firewall.fw[1].name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = local.fwnatrules[index(local.fwnatrules.*.collectionname, each.key)].priority
  action              = local.fwnatrules[index(local.fwnatrules.*.collectionname, each.key)].action

  dynamic rule {
    for_each = { for r in local.fwnatrules.*.rulename :
      r => each.key...
    if each.key == local.fwnatrules[index(local.fwnatrules.*.rulename, r)].collectionname }

    content {
      name = rule.key

      source_addresses = [for s in split(";", local.fwnatrules[index(local.fwnatrules.*.rulename, rule.key)].sourceaddresses) : s]
      #destination_addresses = local.fwnatrules[index(local.fwnatrules.*.name,each.key)].destaddresses == "firewallpublicip"? [azurerm_public_ip.fwpip[1].ip_address] : [for d in split(";",local.fwnatrules[index(local.fwnatrules.*.name,each.key)].destaddresses):d]
      destination_addresses = [azurerm_public_ip.fwpip[1].ip_address]
      destination_ports     = [for d in split(";", local.fwnatrules[index(local.fwnatrules.*.rulename, rule.key)].destport) : d]
      protocols             = [for p in split(";", local.fwnatrules[index(local.fwnatrules.*.rulename, rule.key)].protocols) : p]
      translated_port       = local.fwnatrules[index(local.fwnatrules.*.rulename, rule.key)].translatedport
      translated_address    = local.fwnatrules[index(local.fwnatrules.*.rulename, rule.key)].translatedaddress
    }
  }
}

