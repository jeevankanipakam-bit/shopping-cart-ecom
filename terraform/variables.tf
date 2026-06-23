variable "region" {}
variable "vpc_cidr" {}
variable "subnet_cidr" {}
variable "subnet_cidr_b" {}

variable "vpc_name" {}
variable "subnet_name" {}
variable "igw_name" {}
variable "route_table_name" {}

variable "ami" {}
variable "instance_type" {}

variable "key_name" {}
variable "ec2_ssh_public_key" {}

variable "github_repo_url" {}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}