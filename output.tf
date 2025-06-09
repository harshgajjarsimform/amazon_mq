# -----------------------------
# Basic Broker Information
# -----------------------------
output "mq_broker_arn" {
  description = "ARN of the Amazon MQ broker"
  value       = aws_mq_broker.amazon-mq.arn
}

output "id" {
  description = "Unique ID that Amazon MQ generates for the broker"
  value       = aws_mq_broker.amazon-mq.id
}

# -----------------------------
# Configuration Details
# -----------------------------
output "engine_type" {
  description = "Type of broker engine (ActiveMQ or RabbitMQ)"
  value       = aws_mq_broker.amazon-mq.engine_type
}

output "engine_version" {
  description = "Version of the broker engine"
  value       = aws_mq_broker.amazon-mq.engine_version
}

output "host_instance_type" {
  description = "Broker's instance type"
  value       = aws_mq_broker.amazon-mq.host_instance_type
}

output "deployment_mode" {
  description = "Deployment mode of the broker (SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ)"
  value       = aws_mq_broker.amazon-mq.deployment_mode
}

# -----------------------------
# Instance & Networking Information
# -----------------------------
output "instances" {
  description = "List of information about allocated brokers (both active & standby)"
  value       = aws_mq_broker.amazon-mq.instances
}

output "console_urls" {
  description = "The URLs of the ActiveMQ Web Console or the RabbitMQ Management UI"
  value       = [for instance in aws_mq_broker.amazon-mq.instances : instance.console_url]
}

output "ip_addresses" {
  description = "IP Addresses of the broker instances"
  value       = [for instance in aws_mq_broker.amazon-mq.instances : instance.ip_address]
}

output "endpoints" {
  description = "Broker's wire-level protocol endpoints"
  value       = flatten([for instance in aws_mq_broker.amazon-mq.instances : instance.endpoints])
}

output "primary_instance_endpoints" {
  description = "Primary broker's wire-level protocol endpoints"
  value       = length(aws_mq_broker.amazon-mq.instances) > 0 ? aws_mq_broker.amazon-mq.instances[0].endpoints : []
}

# -----------------------------
# Replication & Data Management
# -----------------------------
output "pending_data_replication_mode" {
  description = "The data replication mode that will be applied after reboot"
  value       = aws_mq_broker.amazon-mq.pending_data_replication_mode
}

# -----------------------------
# Secret Management
# -----------------------------
output "secert_manager_arn" {
  description = "ARN of the Secrets Manager secret containing the broker's credentials"
  value       = var.use_secret_manager ? aws_secretsmanager_secret.mq_secret[0].arn : null
}

# -----------------------------
# Tags
# -----------------------------
output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_mq_broker.amazon-mq.tags_all
}