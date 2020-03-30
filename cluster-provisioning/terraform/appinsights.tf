
resource "azurerm_application_insights" "demo" {
  name                = "${var.prefix}-ai"
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = "web"

#  depends_on = [
#    azurerm_resource_group.demo,
#  ]
}

output "instrumentation_key" {
  value = azurerm_application_insights.demo.instrumentation_key
}

output "app_id" {
  value = azurerm_application_insights.demo.app_id
}