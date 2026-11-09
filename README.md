# Azure Automated Backup System

Terraform project that backs up an Azure file share automatically and emails you when a backup reports a problem.

## What it builds

| Resource | Purpose |
|---|---|
| Resource group | Holds everything in this project |
| Storage account (Standard, LRS) | Holds the file share that is backed up |
| File share | The data being protected |
| Recovery Services vault (locally redundant) | Stores the backups |
| Backup policy | Daily backup, keeps a set number of daily backups |
| Backup container registration + protected file share | Connects the share to the vault using the policy |
| Monitor action group | Sends email to the alert address |
| Metric alert | Fires when the vault reports a backup health event that is not `Healthy` |

All resource names are built from your `yourname` value, and every tunable setting is a variable.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.5 or newer
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription where you can create resources (Contributor role)

## Setup

1. **Log in to Azure.** On WSL or a machine without a browser, use device code. Terraform also needs a Microsoft Graph token, so request that scope:

   ```bash
   az login --use-device-code --tenant "<your-tenant-id>" --scope "https://graph.microsoft.com/.default"
   ```

2. **Set your subscription ID** (needed in every new terminal; it is deliberately not stored in the code):

   ```bash
   export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
   ```

3. **Create your variables file** from the example and edit it:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   `terraform.tfvars` is git-ignored, so your email and name stay local.

4. **Deploy:**

   ```bash
   terraform init
   terraform fmt
   terraform validate
   terraform plan
   terraform apply
   ```

   Read the plan before typing `yes`.

## Variables

Required (no default):

| Variable | Description |
|---|---|
| `yourname` | Short lowercase suffix for resource names. Letters and numbers only. It is part of the storage account name, so keep it at 15 characters or fewer |
| `alert_email` | Address that receives backup alerts |

Optional (defaults in `variables.tf`):

| Variable | Default | Description |
|---|---|---|
| `location` | `East US` | Azure region |
| `tags` | project and env tags | Tags applied to all resources |
| `backup_time` | `23:00` | Daily backup time (HH:MM) |
| `backup_timezone` | `UTC` | Timezone of the schedule |
| `daily_retention_count` | `7` | Daily backups to keep (1 to 200) |
| `file_share_name` | `backupshare` | Name of the file share |
| `file_share_quota_gb` | `5` | Share size limit in GB |
| `storage_account_tier` | `Standard` | Storage account tier |
| `storage_replication_type` | `LRS` | Storage replication |
| `vault_storage_mode` | `LocallyRedundant` | Where the vault keeps backups. Cannot change once items are protected |
| `alert_severity` | `1` | Alert severity (0 to 4) |
| `alert_frequency` | `PT5M` | How often the alert is evaluated |
| `alert_window_size` | `PT15M` | Alert look-back window |
| `action_group_short_name` | `backupalert` | Action group short name (12 characters max) |

## Outputs

`resource_group_name`, `storage_account_name`, `recovery_vault_name`, `backup_policy_id`. Run `terraform output` to print them.

## Verify it works

List the protected item and recent jobs:

```bash
az backup item list --resource-group <rg> --vault-name <vault> --backup-management-type AzureStorage -o table
az backup job list --resource-group <rg> --vault-name <vault> -o table
```

To test a restore: upload a file to the share, run a backup (portal **Backup now**, or `az backup protection backup-now`), delete the file, then restore from the latest recovery point with `az backup restore restore-azurefiles` and confirm the file returns.

## Cost

Small. An idle storage account, a vault with no protected data, and one alert rule cost pennies per month. Cost grows with the amount of data backed up. Check the Azure pricing pages for current figures.

## Destroying the project

Do not run `terraform destroy` straight away. The vault has soft delete enabled (Azure no longer allows turning it off) and the file share has a backup item, so the vault cannot be removed until protection is stopped and its backup data is deleted. Remove those first, then destroy.

## Files

| File | Contents |
|---|---|
| `versions.tf` | Terraform and provider version requirements |
| `providers.tf` | Azure provider configuration |
| `variables.tf` | Input variables |
| `main.tf` | Resources |
| `outputs.tf` | Output values |
| `terraform.tfvars.example` | Template for your own `terraform.tfvars` |

## Security notes

- `terraform.tfvars`, state files, and `.terraform/` are git-ignored. Never commit state: it can contain secrets.
- The subscription ID is passed through the `ARM_SUBSCRIPTION_ID` environment variable, not stored in code.
