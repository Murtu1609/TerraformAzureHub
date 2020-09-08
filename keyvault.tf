
provider "random" {
  version = "~> 2.2"
}

data "azurerm_client_config" "current" {}
/*data "azurerm_client_config" "config" {
  provider = azurerm.backend
}*/
data "azuread_group" "kvaccess" {
  
  name     = var.keyvaultgroup
}


resource "random_string" "rstring" {
  length  = 10
  special = false
  upper   = false
  lower   = true
  number  = true
}

resource "azurerm_key_vault" "hubkv" {
  name                = substr(replace("${var.resourcegroupname}-${random_string.rstring.result}", "/[^0-9A-Za-z\\-]+/", ""), 0, 24)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = azurerm_resource_group.rg.tags

  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enabled_for_disk_encryption     = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Update",
      "Delete",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azuread_group.kvaccess.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Update",
      "Delete",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }

}

resource "random_password" "windows" {
  length      = 15
  min_special = 2
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

resource "azurerm_key_vault_secret" "windowspwd" {
  key_vault_id = azurerm_key_vault.hubkv.id
  name         = "windowspassword"
  content_type = "windowspassword"
  value        = random_password.windows.result
}

resource "azurerm_key_vault_secret" "pubkey" {
  key_vault_id = azurerm_key_vault.hubkv.id

  name         = "ssh-pub-key"
  value        = file(var.publickeypath)
  content_type = "ssh-pub-key"
}



resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.hubkv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.uai.principal_id

  key_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]
}