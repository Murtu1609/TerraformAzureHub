resource "azurerm_log_analytics_workspace" "law" {
  name                = substr(replace("${var.resourcegroupname}-${random_string.rstring.result}", "/[^0-9A-Za-z\\-]+/", ""), 0, 24)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "PerGB2018"
  retention_in_days = 30 // Max 730
  tags              = azurerm_resource_group.rg.tags
}