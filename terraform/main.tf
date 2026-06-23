terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"

  vpc_cidr         = var.vpc_cidr
  subnet_cidr      = var.subnet_cidr
  subnet_cidr_b    = var.subnet_cidr_b
  vpc_name         = var.vpc_name
  subnet_name      = var.subnet_name
  igw_name         = var.igw_name
  route_table_name = var.route_table_name
}

module "ec2" {
  source = "./modules/ec2"

  ami               = var.ami
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  key_name           = var.key_name
  ec2_ssh_public_key = var.ec2_ssh_public_key
  github_repo_url   = var.github_repo_url
}

module "ecr" {
  source = "./modules/ecr"

  repository_name       = var.ecr_repository_name
  image_tag_mutability  = "MUTABLE"
  scan_on_push          = true
}

resource "aws_lb" "app_alb" {
  name               = "shopping-cart-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.network.alb_security_group_id]
  subnets            = [module.network.subnet_id, module.network.subnet_id_b]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "shopping-cart-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = module.ec2.instance_id
  port             = 5000
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_registry_id" {
  description = "AWS Account ID of the ECR registry"
  value       = module.ecr.registry_id
}