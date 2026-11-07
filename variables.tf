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
