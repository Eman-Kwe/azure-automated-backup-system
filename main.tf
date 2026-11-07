resource "azurerm_resource_group" "main" {
  name     = "rg-backup-${var.yourname}" # Name is built from your variable, e.g. "rg-backup-yanny"
  location = var.location                # Azure region from variables.tf
  tags     = var.tags                    # Labels for cost tracking and organisation
}

# Storage account: where backup data will be stored.
resource "azurerm_storage_account" "main" {
  name                     = "stbackup${var.yourname}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard" # Standard = hard disk storage, cheaper than Premium (SSD)
  account_replication_type = "LRS"      # Locally redundant: 3 copies in one datacenter, lowest cost
  tags                     = var.tags
}
