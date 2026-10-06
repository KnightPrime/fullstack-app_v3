output "app_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Public IP address of the server"
  sensitive   = false
}

output "app_url" {
  description = "The HTTP URL to view your deployed application"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}

# 4. Securely output the private key string so the pipeline can read it
output "ec2_private_key" {
  value     = tls_private_key.pipeline_key.private_key_pem
  sensitive = true # Marks the text as hidden in standard console log displays
}

