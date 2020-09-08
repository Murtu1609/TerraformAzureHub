resource "azurerm_storage_account" "bootdiag" {
  name                = substr(replace(lower("${var.resourcegroupname}-${random_string.rstring.result}"), "/[^0-9a-z]+/", ""), 0, 24) // 3-24 lowercase alnum only
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = azurerm_resource_group.rg.tags
}