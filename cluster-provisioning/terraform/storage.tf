resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}logs"
  resource_group_name      = "${var.resource_group}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "logs"
  }
}