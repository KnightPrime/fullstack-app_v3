output "monitoring_public_ip" {
  value       = aws_instance.monitoring_server.public_ip
  description = "Public IP address of the monitoring server"
  sensitive   = false
}

