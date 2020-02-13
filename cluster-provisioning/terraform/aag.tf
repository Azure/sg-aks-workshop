# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${var.azure_vnet_name}-beap"
  frontend_port_name             = "${var.azure_vnet_name}-feport"
  frontend_ip_configuration_name = "${var.azure_vnet_name}-feip"
  http_setting_name              = "${var.azure_vnet_name}-be-htst"
  listener_name                  = "${var.azure_vnet_name}-httplstn"
  request_routing_rule_name      = "${var.azure_vnet_name}-rqrt"
  redirect_configuration_name    = "${var.azure_vnet_name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "sg-appgateway"
  resource_group_name = var.resource_group
  location            = var.location

  sku {
    name     = "WAF_V2"
    tier     = "WAF_V2"
    capacity = 2
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "gw-ip-config"
    subnet_id = var.azure_aag_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.azure_aag_public_ip
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = ["100.64.2.4"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 10
    probe_name            = "IngressControllerHealthy"
  }

  probe {
    host = "100.64.2.4"
    name = "IngressControllerHealthy"
    interval = 30
    protocol = "Http"
    path = "/"
    timeout = 30
    unhealthy_threshold = 3
    match {
    status_code = [
      "200",
      "404"
    ] 
   }
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
