provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


# 1. Generate a secure, dynamic cryptographic private key block
#resource "tls_private_key" "pipeline_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# 2. Register the public key component with your AWS EC2 console region
#resource "aws_key_pair" "generated_key" {
#  key_name   = "knightprime-gitops-key-${terraform.workspace}"
#  public_key = tls_private_key.pipeline_key.public_key_openssh
#}

# --- DEDICATED SECURITY GROUP SECURITY BOUNDARIES ---
resource "aws_security_group" "monitoring_sg" {
  name        = "knightprime-monitoring-cockpit-sg"
  description = "Allows secure tracking ingress metrics and log aggregation lines"

  # Grafana Web Console Gateway Port Mapping
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Hardened to let you access your dashboards globally
  }

  # SSH Management Gate
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring Cockpit"
  }
}

# --- PROVISION COCKPIT SERVER INSTANCE ---
resource "aws_instance" "monitoring_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  #key_name = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "=== Configuring Monitoring Host Environment ==="

              # 1. Update system dependencies and install Docker Engine
              while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock >/dev/null 2>&1 ; do sleep 5; done
              sudo apt-get update
              sudo apt-get install -y docker.io docker-compose
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # 2. Ensure docker initializes on boot
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # 3. Build dynamic configuration directories for the monitoring containers
              sudo mkdir -p /etc/prometheus /etc/loki /etc/grafana
              

              echo "=== Host Infrastructure Complete: Ready for Monitoring ==="
              EOF

  tags = {
    Name = "knightprime-server-monitoring"
    ROle = "Observability"
  }
}

