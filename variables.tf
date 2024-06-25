variable "env" {
   description = "Deployment environment"
   type        = string
}

variable "region" {
   description = "AWS region"
   type        = string
}

variable "ami_id" {
   description = "EC2 Ubuntu AMI"
   type        = string
}

variable "availability_zone" {
  description = "The availability zone to deploy the resources"
  type        = string
  default     = "us-east-1a"  # Default to an AZ, but can be overridden
}
