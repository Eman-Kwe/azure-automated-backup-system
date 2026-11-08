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


# File share: the thing we will back up. Lives inside the storage account.
resource "azurerm_storage_share" "main" {
  name               = "backupshare"                   # Lowercase letters, numbers, hyphens only
  storage_account_id = azurerm_storage_account.main.id # Links the share to the storage account
  quota              = 5                               # Max size in GB
}

# Recovery Services vault: holds the backups and the backup policy.
resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-backup-${var.yourname}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant" # Backups kept in one region only: cheaper for learning
  tags                = var.tags
}

# Backup policy: when to back up and how long to keep each backup.
resource "azurerm_backup_policy_file_share" "daily" {
  name                = "policy-daily-${var.yourname}"
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00" # 24-hour clock, in the timezone above
  }

  retention_daily {
    count = 7 # Keep 7 daily backups
  }
}

# Registers the storage account with the vault so the vault is allowed to back it up.
resource "azurerm_backup_container_storage_account" "main" {
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  storage_account_id  = azurerm_storage_account.main.id
}

# Connects the file share to the vault using the policy: this turns backups on.
resource "azurerm_backup_protected_file_share" "main" {
  resource_group_name       = azurerm_resource_group.main.name
  recovery_vault_name       = azurerm_recovery_services_vault.main.name
  source_storage_account_id = azurerm_storage_account.main.id
  source_file_share_name    = azurerm_storage_share.main.name
  backup_policy_id          = azurerm_backup_policy_file_share.daily.id

  # Container registration must finish first. No attribute links them, so state it explicitly.
  depends_on = [azurerm_backup_container_storage_account.main]
}
