provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


# 1. Generate a secure, dynamic cryptographic private key block
resource "tls_private_key" "pipeline_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Register the public key component with your AWS EC2 console region
resource "aws_key_pair" "generated_key" {
  key_name   = "pipeline-deployed-key"
  public_key = tls_private_key.pipeline_key.public_key_openssh
}

# --- DYNAMIC SECURITY GROUP SEGMENTATION ---
resource "aws_security_group" "app_sg" {
  name        = "knightprime-gitops-sg-${terraform.workspace}"
  description = "Security boundaries isolated dynamically for ${terraform.workspace} environment"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Hardened to let GitHub runners communicate
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

# Launch Clean EC2 Instance executing localized Docker run configurations
resource "aws_instance" "app_server" {
  ami = data.aws_ami.ubuntu.id
  #instance_type          = var.instance_type
  instance_type          = terraform.workspace == "production" ? "t3.micro" : "t4g.small"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  # COMMENTING OUT THIS LINE TO PREVENT EC2 RECREATION EVERYTIME:
  #user_data_replace_on_change = true

  key_name = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "=== Configuring Pipeline Host Environment ==="

              # 1. Update system dependencies and install Docker Engine
              while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock >/dev/null 2>&1 ; do sleep 5; done
              sudo apt-get update -y
              sudo apt-get install -y docker.io

              # 2. Ensure docker initializes on boot
              sudo systemctl start docker
              sudo systemctl enable docker

              echo "=== Host Infrastructure Complete: Ready for Pipeline deployment ==="
              EOF

  tags = {
    Name        = "knightprime-server-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

