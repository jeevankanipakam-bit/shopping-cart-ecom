output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "subnet_id_b" {
  value = aws_subnet.public_subnet_b.id
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}