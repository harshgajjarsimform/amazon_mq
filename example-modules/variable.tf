variable "primary_region" {
  description = "The primary AWS region for the RabbitMQ broker."
  type        = string
}

variable "broker_name" {
  description = "The name of the RabbitMQ broker."
  type        = string
}

variable "engine_type" {
  description = "The type of the RabbitMQ engine."
  type        = string
  validation {
    condition     = contains(["ActiveMQ"], var.engine_type)
    error_message = "Valid values are ActiveMQ or RabbitMQ."
  }
}

variable "engine_version" {
  description = "The version of the RabbitMQ engine."
  type        = string
}

variable "host_instance_type" {
  description = "The instance type for the RabbitMQ broker."
  type        = string
}

variable "mq_users" {
  description = "A object of user details for the RabbitMQ broker."
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

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
variable "security_groups" {
  description = "The list of security group IDs for the RabbitMQ broker."
  type        = list(string)
  default     = []

}
variable "apply_immediately" {
  description = "Whether to apply changes immediately."
  type        = bool
  default     = true

}
/*
## Example XML configuration for RabbitMQ for tfvars

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
  description = "The data of the RabbitMQ configuration."
  type        = string
}

# variable "mq_config_path" {
#   description = "path for the xml file"
#   type = string
# }
variable "custom_config" {
  description = "Whether to use a custom configuration for the RabbitMQ broker."
  type        = bool
  default     = false
}
variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade the RabbitMQ broker to the latest minor version."
  type        = bool
  default     = false
}
variable "deployment_mode" {
  description = "The deployment mode for the RabbitMQ broker."
  type        = string
  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ"], var.deployment_mode)
    error_message = "Valid values are SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ."
  }
}

variable "authentication_strategy" {
  description = "The authentication strategy for the RabbitMQ broker value can be simple or ldap."
  type        = string
}

variable "logs" {
  description = "The logs configuration for the RabbitMQ broker."
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
  description = "The encryption options for the RabbitMQ broker."
  type = object({
    kms_key_id        = string
    use_aws_owned_key = bool
  })
  default = {
    kms_key_id        = null
    use_aws_owned_key = true
  }
}

variable "storage_type" {
  description = "The storage type for the RabbitMQ broker. valid"
  type        = string
}

variable "publicly_accessible" {
  description = "Whether the RabbitMQ broker is publicly accessible."
  type        = bool
  default     = false
}

variable "subnet_ids_primary" {
  description = "The list of subnet IDs for the primary RabbitMQ broker."
  type        = list(string)
  validation {
    condition     = var.deployment_mode != "ACTIVE_STANDBY_MULTI_AZ" || length(var.subnet_ids_primary) >= 2
    error_message = "ACTIVE_STANDBY_MULTI_AZ deployment mode requires at least 2 subnets in different AZs."
  }
}

variable "tags" {
  description = "A map of tags to assign to the RabbitMQ broker."
  type        = map(string)
  default     = {}
}