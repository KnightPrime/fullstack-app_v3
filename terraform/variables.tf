variable "aws_region" {
  type    = string
  default = "us-east-1"
}


# Pulls the latest stable Ubuntu 22.04 LTS AMI automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

/*variable "key_name" {
  type        = string
  description = "The name of your pre-existing AWS EC2 SSH key pair"
}
*/

variable "instance_type" {
  description = "EC2 Instance Size"
  type        = string
  default     = "t3.micro"
}
