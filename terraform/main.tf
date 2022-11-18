terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformDemo"
    storage_account_name = "terraformbackend999"
    container_name       = "tfstatedemo"
    key                  = "tfstatedemo.tfstate"
  }
}
 
provider "azurerm" {
  version = "~>2.0"
  features {}
}

data "azurerm_client_config" "current" {}
 
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}
 
resource "azurerm_virtual_network" "vnet" {
  name                = "paperchase-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus2"
  resource_group_name = var.resource_group_name
}
 
resource "azurerm_subnet" "subnet" {
  name                 = "paperchase-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  location                    = var.region
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name            = "vmpassword"
  value           = random_password.vmpassword.result
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "text/plain"
  expiration_date = var.key_vault_secret_expiration_date

  depends_on = [
    var.keyvault_name
  ]

}

resource "azurerm_network_interface" "paperchasewinnic" {
  name                = "paperchase-nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  depends_on = [
    var.resource_group_name
  ]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

  }

}


resource "azurerm_windows_virtual_machine" "paperchasewinvm" {
  name                       = "pcvm01"
  resource_group_name        = var.resource_group_name
  location                   = var.region
  size                       = var.vm_size
  admin_username             = "kpmgtestadmin"
  admin_password             = azurerm_key_vault_secret.vmpassword.value
  allow_extension_operations = false

  network_interface_ids = [

    azurerm_network_interface.paperchasewinnic.id,

  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage_os_disk_config
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"

  }

  depends_on = [
    azurerm_network_interface.paperchasewinnic,
    azurerm_key_vault_secret.vmpassword
  ]

}

resource "random_password" "vmpassword" {
  length  = 16
  special = true
}


