
resource "azurerm_template_deployment" "domain" {
    for_each = var.createdomain ? toset(["1"]) : []

  name                = "domainservices"
  resource_group_name = azurerm_resource_group.rg.name
template_body = file(var.templatefilepath)

parameters = {
    domainName = var.domainname
    filteredSync = var.filteredsync
    subnetid = azurerm_subnet.subnet[var.domainsubnet].id
}
 deployment_mode = "Incremental"
}