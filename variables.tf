variable "yourname" {
  description = "Short lowercase name used as a suffix in resource names (letters and numbers only, it is also used in the storage account name)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "alert_email" {
  description = "Email address that receives backup failure alerts"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project = "automated-backup"
    env     = "learning"
  }
}

variable "backup_time" {
  description = "Time of day the daily backup runs, 24-hour HH:MM, in backup_timezone"
  type        = string
  default     = "23:00"

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.backup_time))
    error_message = "backup_time must be in 24-hour HH:MM format, for example 23:00."
  }
}

variable "backup_timezone" {
  description = "Timezone used for the backup schedule"
  type        = string
  default     = "UTC"
}

variable "daily_retention_count" {
  description = "Number of daily backups to keep"
  type        = number
  default     = 7

  validation {
    condition     = var.daily_retention_count >= 1 && var.daily_retention_count <= 200
    error_message = "daily_retention_count must be between 1 and 200."
  }
}

variable "file_share_name" {
  description = "Name of the file share that is backed up (lowercase letters, numbers, hyphens)"
  type        = string
  default     = "backupshare"
}

variable "file_share_quota_gb" {
  description = "Maximum size of the file share in GB"
  type        = number
  default     = 5
}

variable "storage_account_tier" {
  description = "Storage account tier: Standard or Premium"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type, for example LRS or GRS"
  type        = string
  default     = "LRS"
}

variable "vault_storage_mode" {
  description = "Where the vault keeps backups: LocallyRedundant, ZoneRedundant or GeoRedundant. Cannot change once items are protected"
  type        = string
  default     = "LocallyRedundant"
}

variable "alert_severity" {
  description = "Severity of the backup failure alert, 0 (critical) to 4 (verbose)"
  type        = number
  default     = 1

  validation {
    condition     = var.alert_severity >= 0 && var.alert_severity <= 4
    error_message = "alert_severity must be between 0 and 4."
  }
}

variable "alert_frequency" {
  description = "How often the alert rule is evaluated, ISO 8601 duration (for example PT5M)"
  type        = string
  default     = "PT5M"
}

variable "alert_window_size" {
  description = "Look-back period for the alert rule, ISO 8601 duration. Must be at least alert_frequency"
  type        = string
  default     = "PT15M"
}

variable "action_group_short_name" {
  description = "Short name of the alert action group (maximum 12 characters)"
  type        = string
  default     = "backupalert"

  validation {
    condition     = length(var.action_group_short_name) <= 12
    error_message = "action_group_short_name must be 12 characters or fewer."
  }
}
