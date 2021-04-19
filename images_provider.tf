provider "azurerm" {
  // Uses the Azure CLI token (or env vars) unless managed identity is used
  features {}
  subscription_id = var.images_subscription
  alias   = "images"
  use_msi = false
}