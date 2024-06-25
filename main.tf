terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }
backend "s3" {
    bucket = "mgh-my-bucket"
    key    = "tfstate.json"
    region = "us-east-1"
    # optional: dynamodb_table = "<table-name>"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region  = var.region
  profile = "default"  # change in case you want to work with another AWS account profile
}

resource "aws_security_group" "mgh-netflix-app-sg" {
  name        = "mgh-netflix-app-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use the aws_key_pair resource to provision a Key-pair and use it in your instance.
resource "aws_key_pair" "machine1" {
  key_name   = "machine1.pem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIgfmMQSso7vZfGFJg4rQkKVyxoBjw2zncQjTUgg5vDNBETMOvoYJ8SXssDj9hQCZ7mBDILiqLiDEqANIanNMmhRccmRNt4h5nqIO+WmUPCdqfcj9EDigF5jmuRYOIaAm5XQKkcG/sMXnTKLHtOHPCHBwyGQOKNqtLehzxNRT2lveV7gAnf8x7m5KCfr670jcCzM5E/xVenxHM2p1k5BWsOy720Ax0gjKQrbuXdX5pG+Ueasifa/3pGPZ65noy4Rd+OD+Ybmo5b0QjyjUshA2Xgv6RMaVcxjkTFr65lGBphx0h9Vzhbzzpcua75WM6KIRmF7/YXO17VVzmcScocRIf"
}

# Use the aws_ebs_volume resource to create an 5GB EBS volume and attach it to your instance.
resource "aws_ebs_volume" "mgh-tf-volume" {
  availability_zone = var.availability_zone
  size              = 5
}

resource "aws_volume_attachment" "mgh-tf-attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.mgh-tf-volume.id
  instance_id = aws_instance.netflix_app.id
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "mgh-my-bucket"
}

resource "aws_instance" "netflix_app" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.mgh-netflix-app-sg.name]
  key_name = aws_key_pair.machine1.key_name
  user_data = file("./deploy.sh")
  availability_zone = var.availability_zone

  tags = {
    Name = "mgh-tf-basics-${var.env}"
  }

  depends_on = [aws_s3_bucket.my_bucket]
}


