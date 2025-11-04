output "public_ip_instance_a" {
  description = "Public IP address of Instance A (Vote/Result/Bastion)"
  value       = aws_instance.instance_a.public_ip
}
output "private_ip_instance_b" {
  description = "Private IP address of Instance B (Redis/Worker)"
  value       = aws_instance.instance_b.private_ip
}
output "private_ip_instance_c" {
  description = "Private IP address of Instance C (PostgreSQL)"
  value       = aws_instance.instance_c.private_ip
}

# SSH Config Output
output "ssh_config" {
  value = <<EOF
Host instance_a
  HostName ${aws_instance.instance_a.public_ip}
  User ubuntu
  IdentityFile ~/.ssh/aws_key.pub

Host instance_b
  HostName ${aws_instance.instance_b.private_ip}
  User ubuntu
  IdentityFile ~/.ssh/aws_key_private.pub
  ProxyJump instance_a

Host instance_c
  HostName ${aws_instance.instance_c.private_ip}
  User ubuntu
  IdentityFile ~/.ssh/aws_key_private.pub
  ProxyJump instance_a
EOF
}