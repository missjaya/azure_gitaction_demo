variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "paperchase-rg"
}

variable "virtual_network_name" {
  description = "Virtual network name."
  type        = string
  default     = "pc-vnet"
}

variable "region" {
  description = "Resource deployment location."
  type        = string
  default     = "eastus2"
}

variable "keyvault_name" {
  description = "Name of the Key Vault."
  type        = string
  default     = "pc-kv07693"
}

variable "vm_size" {
  description = "Size (SKU) of the Virtual Machine to create."
  type        = string
  default     = "Standard_B1s"
}

variable "storage_os_disk_config" {
  description = "Map to configure OS storage disk. (Caching, size, storage account type...)."
  type        = string
  default     = "Standard_LRS"
}

variable "access_policies" {
  description = "List of access policy permissions."
  default     = []
}

variable "key_vault_secret_expiration_date" {
  description = "KeyVault secret expiration date."
  type        = string
  default     = "2022-11-30T20:00:00Z"
}