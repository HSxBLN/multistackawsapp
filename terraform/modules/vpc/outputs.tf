output "public_subnet_a_id" {
  description = "ID of the public subnet in availability zone A"
  value       = aws_subnet.public_a.id
}
output "private_subnet_b_id" {
  description = "ID of the private subnet in availability zone B"
  value       = aws_subnet.private_b.id
}
output "private_subnet_c_id" {
  description = "ID of the private subnet in availability zone C"
  value       = aws_subnet.private_c.id
}
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
output "vote_result_bastion_sg_id" {
  description = "Security Group ID for Vote Result Bastion Instance"
  value       = aws_security_group.vote_result_bastion_sg.id
}
output "redis_worker_sg_id" {
  description = "Security Group ID for Redis Worker Instance"
  value       = aws_security_group.redis_worker_sg.id
}
output "postgresql_sg_id" {
  description = "Security Group ID for PostgreSQL Instance"
  value       = aws_security_group.postgresql_sg.id
}  
