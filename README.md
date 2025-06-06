# AWS Amazon MQ Terraform Module

This Terraform module deploys an Amazon MQ broker with configurable options for ActiveMQ engine type. The module supports both single-instance and multi-AZ deployments with customizable configurations.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.11 |
| aws | ~> 5.0 |

## Features

- Supports ActiveMQ engine type
- Multiple deployment modes (SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ)
- Custom broker configuration
- Configurable security groups and subnet placement
- Flexible authentication strategies
- Encryption options
- Logging configuration
- Maintenance window scheduling

## Usage

```hcl
module "amazon-mq" {
  source = "path/to/module"

  broker_name        = "activemq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.18"
  storage_type       = "efs"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"
  primary_region     = "ap-south-1"

  apply_immediately = true

  custom_config  = true
  mq_config_data = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
    <statisticsBrokerPlugin/>
    <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
  </plugins>
</broker>
XML

  authentication_strategy = "simple"
  mq_users = {
    username = "admin"
    password = "StrongPassword123!"
  }

  auto_minor_version_upgrade = true
  publicly_accessible        = false
  subnet_ids_primary         = ["subnet-12345678", "subnet-87654321"] 
  security_groups            = ["sg-12345678"]

  logs = {
    general = true
    audit   = true
  }

  encryption_options = {
    kms_key_id        = null
    use_aws_owned_key = true
  }

  maintenance_window_start_time = {
    day_of_week = "MONDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  tags = {
    "env"  = "dev",
    "team" = "messaging"
  }
}
```

## Example .tfvars file

```hcl
primary_region             = "ap-south-1"
broker_name                = "activemq"
engine_type                = "ActiveMQ"
engine_version             = "5.18"
host_instance_type         = "mq.m5.large"
deployment_mode            = "ACTIVE_STANDBY_MULTI_AZ"
auto_minor_version_upgrade = true
publicly_accessible        = false
storage_type               = "efs"
apply_immediately          = true

authentication_strategy = "simple"

security_groups    = ["sg-00d5b55b331ca8f1e"]
subnet_ids_primary = ["subnet-07b30c16b2937ca11", "subnet-0cc668bb1d4d78f64"] # Need at least 2 subnets in different AZs

custom_config  = true
mq_config_data = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<broker xmlns="http://activemq.apache.org/schema/core">
  <plugins>
    <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
    <statisticsBrokerPlugin/>
    <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
  </plugins>
</broker>
XML

mq_users = {
  username = "admin"
  password = "StrongPassword123!"
}

maintenance_window_start_time = {
  day_of_week = "MONDAY"
  time_of_day = "03:00"
  time_zone   = "UTC"
}

logs = {
  general = true
  audit   = true
}

tags = {
  "env"  = "dev",
  "team" = "messaging"
}

encryption_options = {
  kms_key_id        = null
  use_aws_owned_key = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| primary_region | The primary AWS region for the RabbitMQ broker | `string` | n/a | yes |
| broker_name | The name of the RabbitMQ broker | `string` | n/a | yes |
| engine_type | The type of the RabbitMQ engine | `string` | n/a | yes |
| engine_version | The version of the RabbitMQ engine | `string` | n/a | yes |
| host_instance_type | The instance type for the RabbitMQ broker | `string` | n/a | yes |
| mq_users | A object of user details for the RabbitMQ broker | `object({username=string, password=string})` | n/a | yes |
| storage_type | The storage type for the RabbitMQ broker | `string` | n/a | yes |
| authentication_strategy | The authentication strategy for the RabbitMQ broker | `string` | n/a | yes |
| deployment_mode | The deployment mode for the RabbitMQ broker | `string` | n/a | yes |
| subnet_ids_primary | The list of subnet IDs for the primary RabbitMQ broker | `list(string)` | n/a | yes |
| mq_config_data | The data of the RabbitMQ configuration | `string` | n/a | yes |
| maintenance_window_start_time | The maintenance time details | `object` | `{day_of_week="SUNDAY", time_of_day="02:00", time_zone="UTC"}` | no |
| security_groups | The list of security group IDs for the RabbitMQ broker | `list(string)` | `[]` | no |
| apply_immediately | Whether to apply changes immediately | `bool` | `true` | no |
| custom_config | Whether to use a custom configuration for the RabbitMQ broker | `bool` | `false` | no |
| auto_minor_version_upgrade | Whether to automatically upgrade to the latest minor version | `bool` | `false` | no |
| publicly_accessible | Whether the RabbitMQ broker is publicly accessible | `bool` | `false` | no |
| logs | The logs configuration for the RabbitMQ broker | `object` | `{general=true, audit=true}` | no |
| encryption_options | The encryption options for the RabbitMQ broker | `object` | `{kms_key_id=null, use_aws_owned_key=true}` | no |
| tags | A map of tags to assign to the RabbitMQ broker | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the Amazon MQ broker |
| id | Unique ID that Amazon MQ generates for the broker |
| instances | List of information about allocated brokers (both active & standby) |
| console_urls | The URLs of the ActiveMQ Web Console or the RabbitMQ Management UI |
| ip_addresses | IP Addresses of the broker instances |
| endpoints | Broker's wire-level protocol endpoints |
| primary_instance_endpoints | Primary broker's wire-level protocol endpoints |
| pending_data_replication_mode | The data replication mode that will be applied after reboot |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider |
| engine_type | Type of broker engine (ActiveMQ or RabbitMQ) |
| engine_version | Version of the broker engine |
| host_instance_type | Broker's instance type |
| deployment_mode | Deployment mode of the broker (SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ) |

## Examples

For more examples, see the [example-modules](example-modules/) directory.

