terraform {
  required_version = ">=1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.primary_region
}


module "amazon-mq" {
  source = "../"

  broker_name        = var.broker_name
  engine_type        = var.engine_type
  engine_version     = var.engine_version
  storage_type       = var.storage_type
  host_instance_type = var.host_instance_type
  deployment_mode    = var.deployment_mode
  primary_region     = var.primary_region

  apply_immediately = var.apply_immediately

  custom_config  = var.custom_config
  mq_config_data = var.mq_config_data

  authentication_strategy = var.authentication_strategy
  mq_users                = var.mq_users

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  publicly_accessible = var.publicly_accessible
  subnet_ids_primary  = var.subnet_ids_primary
  security_groups     = var.security_groups

  logs               = var.logs
  encryption_options = var.encryption_options


  maintenance_window_start_time = var.maintenance_window_start_time

  tags = var.tags

}