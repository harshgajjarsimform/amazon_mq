output "endpoints" {
  value = module.amazon-mq.endpoints
}

output "console_url" {
  value = module.amazon-mq.console_urls
}

output "secret_arn" {
  value = module.amazon-mq.secert_manager_arn
}