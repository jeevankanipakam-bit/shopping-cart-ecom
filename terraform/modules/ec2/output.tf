output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "instance_elastic_ip" {
  description = "Elastic IP assigned to the EC2 instance"
  value       = aws_eip.web_server_eip.public_ip
}

output "instance_eip_allocation_id" {
  description = "Elastic IP allocation ID"
  value       = aws_eip.web_server_eip.allocation_id
}

output "instance_id" {
  value = aws_instance.web_server.id
}