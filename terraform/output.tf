output "app_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Public IP address of the server"
}

output "app_url" {
  description = "The HTTP URL to view your deployed application"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}

