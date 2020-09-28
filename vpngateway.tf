
/*resource "azurerm_subnet" "gwsub" {
  for_each             = var.vpngw ? toset(["1"]) : []
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.gwaddress]

}*/

resource "azurerm_public_ip" "gwpip" {
  for_each            = var.vpngw ? toset(["1"]) : []
  name                = "gatewaypip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation

  allocation_method = "Dynamic"
  tags              = azurerm_resource_group.rg.tags
  #domain_name_label = "${var.resourcegroupname}-${random_string.rstring.result}"
}


resource "azurerm_virtual_network_gateway" "vpngw" {
  for_each = var.vpngw ? toset(["1"]) : []

  name                = "vpngw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resourcegrouplocation


  type       = "Vpn"
  vpn_type   = "RouteBased"
  enable_bgp = true
  sku        = var.vpnmultiaz ? "VpnGw${var.vpnsku}AZ" : "VpnGw${var.vpnsku}"
  generation = "Generation2"
  tags       = azurerm_resource_group.rg.tags

  ip_configuration {
    name                          = "vpngwIpConfig"
    public_ip_address_id          = azurerm_public_ip.gwpip[1].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet[var.gwsubnet].id
  }


  dynamic "vpn_client_configuration" {
    for_each = var.vpnclient ? [1] : []

    content {
      address_space = var.clientaddress

      vpn_client_protocols = ["OpenVPN"]

      root_certificate {
        name             = var.vpncertname
        public_cert_data = file(var.vpncertpath)
      }
    }
  }
}