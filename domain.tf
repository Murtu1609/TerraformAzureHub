
resource "azurerm_subnet" "domainsub" {
  for_each = var.createdomain ? toset(["1"]) : []

  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  name             = "domainservices"
  address_prefixes = [var.domainsubnet]
}


resource "azurerm_template_deployment" "domain" {
    for_each = var.createdomain ? toset(["1"]) : []

  name                = "domainservices"
  resource_group_name = azurerm_resource_group.rg.name
template_body = file(var.templatefilepath)

parameters = {
    domainName = var.domainname
    filteredSync = var.filteredsync
    subnetid = azurerm_subnet.domainsub[1].id
}
 deployment_mode = "Incremental"
}