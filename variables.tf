###################################
# Basic Broker Configuration
###################################

variable "primary_region" {
  description = "The primary AWS region for the AmazonMQ () broker."
  type        = string
}

variable "broker_name" {
  description = "The name of the AmazonMQ () broker."
  type        = string
}

variable "engine_type" {
  description = "The type of the AmazonMQ () engine."
  type        = string
  validation {
    condition     = contains(["ActiveMQ", "RabbitMQ"], var.engine_type)
    error_message = "Valid values are ActiveMQ or RabbitMQ ."
  }
}

variable "engine_version" {
  description = "The version of the AmazonMQ (activeMQ) engine."
  type        = string
}

variable "host_instance_type" {
  description = "The instance type for the AmazonMQ broker."
  type        = string
}

variable "deployment_mode" {
  description = "The deployment mode for the AmazonMQ broker."
  type        = string
  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ","CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "Valid values are SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ."
  }
}

variable "storage_type" {
  description = "The storage type for the AmazonMQ () broker. valid"
  type        = string
  validation {
    condition     = contains(["ebs", "efs"], var.storage_type)
    error_message = "Valid values are ebs or efs."
  }
}

variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade the AmazonMQ () broker to the latest minor version."
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
  description = "The authentication strategy for the AmazonMQ () broker value can be simple or ldap."
  type        = string
}

variable "mq_username" {
  description = "A username details for the AmazonMQ () broker."
  type        = string
  sensitive   = true
}

variable "mq_password" {
  description = "value can be random password or secret manager"
  type        = string
  sensitive   = true
  default     = null
}

variable "use_secret_manager" {
  description = "True if secret manager is used for storing password"
  type        = bool
}

variable "security_groups" {
  description = "The list of security group IDs for the AmazonMQ () broker."
  type        = list(string)
  default     = []
}

###################################
# Network Configuration
###################################

variable "publicly_accessible" {
  description = "Whether the AmazonMQ () broker is publicly accessible."
  type        = bool
  default     = false
}

variable "subnet_ids_primary" {
  description = "The list of subnet IDs for the primary AmazonMQ () broker."
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
  description = "Whether to use a custom configuration for the AmazonMQ () broker."
  type        = bool
  default     = false
}


/*
## Example XML configuration for AmazonMQ () for tfvars

mq_config_data = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<broker xmlns="http://.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
  </plugins>
</broker>
XML
*/
variable "mq_config_data" {
  description = "The data of the AmazonMQ () configuration."
  type        = string
  default = null
  validation {
    condition = (
      !var.custom_config || (var.custom_config && var.mq_config_data != null && var.mq_config_data != "")
    )
    error_message = "You must provide mq_config_data when custom_config is true."
  }
}

###################################
# Encryption & Logs
###################################

variable "logs" {
  description = "The logs configuration for the AmazonMQ () broker."
  type = object({
    general = bool
    audit   = bool
  })
  default = {
    general = true
    audit   = true
  }
  validation {
    condition = (
      var.engine_type == "ActiveMQ" || (var.engine_type != "ActiveMQ" && var.logs.audit == false)
    )
    error_message = "logs.audit can only be true when engine_type is 'ActiveMQ'."
  }
}

variable "encryption_options" {
  description = "The encryption options for the AmazonMQ () broker."
  type = object({
    kms_key_id        = string
    use_aws_owned_key = bool
  })
  default = {
    kms_key_id        = null
    use_aws_owned_key = true
  }

  validation {
    condition = (
    var.encryption_options.use_aws_owned_key || (!var.encryption_options.use_aws_owned_key && var.encryption_options.kms_key_id != null && var.encryption_options.kms_key_id != ""))
    error_message = "Specify a KMS key ID only if use_aws_owned_key is false."
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
  secretsmanager_name = var.use_secret_manager ? "${var.secretsmanager_name}-${var.broker_name}-mq-secret" : null
  json_secret = jsonencode({
    username = var.mq_username
    password = var.use_secret_manager ? random_password.random_mq_password[0].result : var.mq_password
  })
}

variable "secretsmanager_name" {
  description = "The name of the Secrets Manager secret."
  type        = string
  default     = null

  validation {
    condition     = (!var.use_secret_manager || (var.use_secret_manager && var.secretsmanager_name != null && var.secretsmanager_name != ""))
    error_message = "You must specify a Secrets Manager name when use_secret_manager is true."
  }
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