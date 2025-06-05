# Variables file with some misconfigurations

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = "defaultpassword123"  # Default password is a security issue
  # sensitive   = true  # Should be marked as sensitive
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access resources"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Too permissive default
}

variable "enable_encryption" {
  description = "Enable encryption for resources"
  type        = bool
  default     = false  # Should default to true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 0  # Should be > 0
}

variable "public_access" {
  description = "Enable public access"
  type        = bool
  default     = true  # Should default to false
}

variable "api_key" {
  description = "API key for external service"
  type        = string
  default     = "sk-1234567890abcdef"  # Hardcoded API key
}
