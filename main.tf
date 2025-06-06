resource "aws_mq_configuration" "mq_config" {
  count          = var.custom_config ? 1 : 0
  name           = var.broker_name
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = var.mq_config_data
}

resource "aws_mq_broker" "amazon-mq" {

  apply_immediately          = var.apply_immediately
  broker_name                = var.broker_name
  engine_type                = var.engine_type
  engine_version             = var.engine_version
  host_instance_type         = var.host_instance_type
  security_groups            = var.publicly_accessible ? [] : var.security_groups
  deployment_mode            = var.deployment_mode
  publicly_accessible        = var.publicly_accessible
  subnet_ids                 = var.publicly_accessible ? null : var.subnet_ids_primary
  storage_type               = var.storage_type
  authentication_strategy    = var.authentication_strategy
  auto_minor_version_upgrade = var.auto_minor_version_upgrade


  maintenance_window_start_time {
    day_of_week = var.maintenance_window_start_time.day_of_week
    time_of_day = var.maintenance_window_start_time.time_of_day
    time_zone   = var.maintenance_window_start_time.time_zone
  }

  dynamic "configuration" {
    for_each = var.custom_config ? [1] : []
    content {
      id       = aws_mq_configuration.mq_config[0].id
      revision = aws_mq_configuration.mq_config[0].latest_revision
    }
  }

  logs {
    general = var.logs.general
    audit   = var.engine_type == "ActiveMQ" ? var.logs.audit : false
  }

  user {
    username = var.mq_users.username
    password = var.mq_users.password
  }

  encryption_options {
    kms_key_id        = var.encryption_options.kms_key_id != null ? var.encryption_options.kms_key_id : null
    use_aws_owned_key = var.encryption_options.use_aws_owned_key
  }

  tags = var.tags
}
