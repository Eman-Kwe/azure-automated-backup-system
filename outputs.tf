output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account that holds the file share"
  value       = azurerm_storage_account.main.name
}

output "recovery_vault_name" {
  description = "Name of the Recovery Services vault"
  value       = azurerm_recovery_services_vault.main.name
}

output "backup_policy_id" {
  description = "ID of the daily file share backup policy"
  value       = azurerm_backup_policy_file_share.daily.id
}

