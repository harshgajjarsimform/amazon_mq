resource "aws_mq_configuration" "mq_config" {
  count          = var.custom_config ? 1 : 0
  name           = var.broker_name
  engine_type    = var.engine_type
  engine_version = var.engine_version
  data           = var.mq_config_data
}

resource "random_password" "random_mq_password" {
  count       = var.use_secret_manager ? 1 : 0
  length      = 16
  special     = true
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

resource "aws_secretsmanager_secret" "mq_secret" {
  count                   = var.use_secret_manager ? 1 : 0
  name                    = local.secretsmanager_name
  description             = "MQ user credentials for ${var.broker_name}"
  recovery_window_in_days = var.recovery_window_in_days
  tags       = var.secretsmanager_tags
}

resource "aws_secretsmanager_secret_version" "mq_secret_version" {
  count         = var.use_secret_manager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.mq_secret[0].id
  secret_string = local.json_secret
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
    username = var.mq_username
    password = var.use_secret_manager ? random_password.random_mq_password[0].result : var.mq_password
  }

  encryption_options {
    kms_key_id        = var.encryption_options.kms_key_id != null ? var.encryption_options.kms_key_id : null
    use_aws_owned_key = var.encryption_options.use_aws_owned_key
  }

  tags = var.tags

  depends_on = [ aws_secretsmanager_secret.mq_secret ]
}
