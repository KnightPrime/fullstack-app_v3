provider "aws" {
  region = var.aws_region
}

# Security Group remains identical (allowing HTTP on 80 and SSH on 22)
resource "aws_security_group" "app_sg" {
  name        = "app-security-group-docker"
  description = "Allow inbound traffic on port 80 and 22"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Clean EC2 Instance executing localized Docker run configurations
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              # CACHE BUSTER COMMENT TO FORCE TERRAFORM REBUILD: v2.0.1
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "=== Starting Fresh Docker Deployment Pipeline ==="

              # 1. Clear system apt updates cleanly
              while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock >/dev/null 2>&1 ; do sleep 5; done
              sudo apt-get update -y
              sudo apt-get install -y docker.io git

              # 2. Boot up docker services on the host machine
              sudo systemctl start docker
              sudo systemctl enable docker

              # 3. Pull down the repository fresh from GitHub
              cd /home/ubuntu
              sudo rm -rf sample-app
              git clone https://github.com/KnightPrime/fullstack-app_v2 app
              cd app

              echo "Building the multi-stage fullstack Docker image..."
              sudo docker build -t fullstack-app:latest .

              # 4. Stop any old instances and run the new container on port 80
              sudo docker stop app-runtime 2>/dev/null || true
              sudo docker rm app-runtime 2>/dev/null || true
              
              echo "Launching the fullstack app container..."
              sudo docker run -d --name app-runtime --restart always -p 80:80 fullstack-app:latest

              echo "=== Docker Deployment Pipeline Completed ==="
              EOF

  tags = {
    Name = "DockerAppServer"
  }
}

