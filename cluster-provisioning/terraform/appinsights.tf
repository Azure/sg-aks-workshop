resource "azurerm_resource_group" "demo" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_application_insights" "demo" {
  name                = "${var.prefix}-ai"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  application_type    = "web"
}

output "instrumentation_key" {
  value = "${azurerm_application_insights.demo.instrumentation_key}"
}

output "app_id" {
  value = "${azurerm_application_insights.demo.app_id}"
}