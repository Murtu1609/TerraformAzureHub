resource "azurerm_recovery_services_vault" "recvault" {
  for_each = var.recoveryvault ? toset(["1"]) : []

  name                = "${var.resourcegroupname}-${random_string.rstring.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location


  sku                 = "Standard"
  soft_delete_enabled = false
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_backup_policy_vm" "bp" {

  for_each = var.recoveryvault ? toset(["1"]) : []

  name                = var.backuppolicy.name
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.recvault[1].name

  timezone = var.backuppolicy.timezone

  backup {
    frequency = var.backuppolicy.frequency
    time      = var.backuppolicy.time
  }

  dynamic retention_daily {
    for_each = var.backuppolicy.dailyretentioncount != "na" ? ["1"] : []

    content {
      count = var.backuppolicy.dailyretentioncount
    }
  }

  dynamic retention_weekly {
    for_each = var.backuppolicy.weeklyretentioncount != "na" ? ["1"] : []

    content {
      count    = var.backuppolicy.weeklyretentioncount
      weekdays = var.backuppolicy.wdays
    }
  }

  dynamic retention_monthly {
    for_each = var.backuppolicy.monthlyretentioncount != "na" ? ["1"] : []
    content {
      count    = var.backuppolicy.monthlyretentioncount
      weekdays = var.backuppolicy.mdays
      weeks    = var.backuppolicy.mweeks
    }
  }

  dynamic retention_yearly {
    for_each = var.backuppolicy.yearlyretentioncount != "na" ? ["1"] : []
    content {
      count    = var.backuppolicy.yearlyretentioncount
      weekdays = var.backuppolicy.ydays
      weeks    = var.backuppolicy.yweeks
      months   = var.backuppolicy.ymonths
    }
  }
}
