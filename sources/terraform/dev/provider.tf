provider "aws" {
  region = var.region
  #shared_credentials_files = ["C:/Users/Administrados/aws_credentials"]
  access_key = "XXXXXXXXXXXXXXXXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}