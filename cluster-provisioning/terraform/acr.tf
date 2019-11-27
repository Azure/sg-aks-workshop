resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_container_registry" "acr" {
<<<<<<< HEAD
  name                = "${var.prefix}acr"
=======
  name                = "${var.prefix}-acr"
>>>>>>> 29c62be1681cb0d6e395f1f89076b21e75c763c0
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  sku                 = "Standard"
  admin_enabled       = false
<<<<<<< HEAD
}
=======
}
>>>>>>> 29c62be1681cb0d6e395f1f89076b21e75c763c0
