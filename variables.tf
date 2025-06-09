###################################
# Basic Broker Configuration
###################################

variable "primary_region" {
  description = "The primary AWS region for the AmazonMQ (activeMQ) broker."
  type        = string
}

variable "broker_name" {
  description = "The name of the AmazonMQ (activeMQ) broker."
  type        = string
}

variable "engine_type" {
  description = "The type of the AmazonMQ (activeMQ) engine."
  type        = string
  validation {
    condition     = contains(["ActiveMQ"], var.engine_type)
    error_message = "Valid values are ActiveMQ or AmazonMQ (activeMQ)."
  }
}

variable "engine_version" {
  description = "The version of the AmazonMQ (activeMQ) engine."
  type        = string
}

variable "host_instance_type" {
  description = "The instance type for the AmazonMQ (activeMQ) broker."
  type        = string
}

variable "deployment_mode" {
  description = "The deployment mode for the AmazonMQ (activeMQ) broker."
  type        = string
  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ"], var.deployment_mode)
    error_message = "Valid values are SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ."
  }
}

variable "storage_type" {
  description = "The storage type for the AmazonMQ (activeMQ) broker. valid"
  type        = string
}

variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade the AmazonMQ (activeMQ) broker to the latest minor version."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the amazonMQ broker."
  type        = map(string)
  default     = {}
}

###################################
# Authentication & Security
###################################

variable "authentication_strategy" {
  description = "The authentication strategy for the AmazonMQ (activeMQ) broker value can be simple or ldap."
  type        = string
}

variable "mq_username" {
  description = "A username details for the AmazonMQ (activeMQ) broker."
  type        = string
  sensitive   = true
}

variable "mq_password" {
  description = "value can be random password or secret manager"
  type        = string
  sensitive   = true
  default = null
}

variable "use_secret_manager" {
  description = "True if secret manager is used for storing password"
  type        = bool
}

variable "security_groups" {
  description = "The list of security group IDs for the AmazonMQ (activeMQ) broker."
  type        = list(string)
  default     = []
}

###################################
# Network Configuration
###################################

variable "publicly_accessible" {
  description = "Whether the AmazonMQ (activeMQ) broker is publicly accessible."
  type        = bool
  default     = false
}

variable "subnet_ids_primary" {
  description = "The list of subnet IDs for the primary AmazonMQ (activeMQ) broker."
  type        = list(string)
  validation {
    condition     = var.deployment_mode != "ACTIVE_STANDBY_MULTI_AZ" || length(var.subnet_ids_primary) >= 2
    error_message = "ACTIVE_STANDBY_MULTI_AZ deployment mode requires at least 2 subnets in different AZs."
  }
}

###################################
# Broker Configuration
###################################

variable "custom_config" {
  description = "Whether to use a custom configuration for the AmazonMQ (activeMQ) broker."
  type        = bool
  default     = false
}


/*
## Example XML configuration for AmazonMQ (activeMQ) for tfvars

mq_config_data = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
  </plugins>
</broker>
XML
*/
variable "mq_config_data" {
  description = "The data of the AmazonMQ (activeMQ) configuration."
  type        = string
}

###################################
# Encryption & Logs
###################################

variable "logs" {
  description = "The logs configuration for the AmazonMQ (activeMQ) broker."
  type = object({
    general = bool
    audit   = bool
  })
  default = {
    general = true
    audit   = true
  }
}

variable "encryption_options" {
  description = "The encryption options for the AmazonMQ (activeMQ) broker."
  type = object({
    kms_key_id        = string
    use_aws_owned_key = bool
  })
  default = {
    kms_key_id        = null
    use_aws_owned_key = true
  }
}

###################################
# Maintenance Configuration
###################################

variable "maintenance_window_start_time" {
  description = "The maintenance time, in 24-hour format. e.g. 02:00, UTC offset format. e.g. CET, day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY"
  type = object({
    day_of_week = string
    time_of_day = string
    time_zone   = string
  })
  default = {
    day_of_week = "SUNDAY"
    time_of_day = "02:00"
    time_zone   = "UTC"
  }
}

###################################
# SecretsManager Configuration
###################################

locals {
  secretsmanager_name        = "${var.secretsmanager_name}-${var.broker_name}-mq-secret"
  json_secretsmanager_policy = jsonencode(var.secretsmanager_policy)
}

variable "secretsmanager_name" {
  description = "The name of the Secrets Manager secret."
  type        = string
}

variable "secretsmanager_policy" {
  description = "The policy for the Secrets Manager secret."
  type        = string
  default     = <<EOT
  {
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      }
    ]
  }
  EOT
}

variable "secretsmanager_tags" {
  description = "A map of tags to assign to the Secrets Manager secret."
  type        = map(string)
  default     = {}
}

variable "recovery_window_in_days" {
  description = "The recovery window in days for the Secrets Manager secret."
  type        = number
  default     = 7
}