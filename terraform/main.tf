# Ironhack Lab 1 - Terraform VPC and EC2 Instance
# Backenend: S3 Bucket for State Management
terraform {
  backend "s3" {
    bucket         = "hauke-ironhack-lab1-state-bucketv2"
    key            = "main/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile   = true            
    encrypt        = true
  }
}
# VPC + Subnets Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = "10.2.0.0/16"
  public_subnet_a_cidr = "10.2.1.0/24"
  private_subnet_b_cidr = "10.2.2.0/24"
  private_subnet_c_cidr = "10.2.3.0/24"
  az_public_a    = "us-west-2a"
  az_private_b   = "us-west-2b"
  az_private_c   = "us-west-2c"
}


# SSH Key Pairs
# First Key Bastion Host (Instance A)
resource "aws_key_pair" "bastion_key" {
  key_name   = "hauke-pub-deployer-key"
  public_key = file("~/.ssh/aws_key.pub") 
}

# Second Key Bastion→Backend (Instance B and C)
resource "aws_key_pair" "backend_key" {
  key_name   = "hauke-private-backend-key"
  public_key = file("~/.ssh/aws_key_private.pub")
}


# EC2 Instances
# Public Instance A Running Vote, Result and Ansible Bastion Host Container
resource "aws_instance" "instance_a" {
  ami = "ami-00f46ccd1cbfb363e"
  instance_type = "t2.micro"
  subnet_id = module.vpc.public_subnet_a_id
  vpc_security_group_ids = [module.vpc.vote_result_bastion_sg_id]
  associate_public_ip_address = true
  key_name = aws_key_pair.bastion_key.key_name
  
  tags = {
    Name = "hauke-instance-a"
    Tier = "public"
    }
}
# Private Instance B Running Redis and Worker Container
resource "aws_instance" "instance_b" {
  ami = "ami-00f46ccd1cbfb363e"
  instance_type = "t3.micro"
  subnet_id = module.vpc.private_subnet_b_id
  vpc_security_group_ids = [module.vpc.redis_worker_sg_id]
  associate_public_ip_address = false
  key_name = aws_key_pair.backend_key.key_name
  tags = {
    Name = "hauke-instance-b"
    Tier = "private"
    }
}
# Private Instance C Running PostgreSQL Container
resource "aws_instance" "instance_c" {
  ami = "ami-00f46ccd1cbfb363e"
  instance_type = "t2.micro"
  subnet_id = module.vpc.private_subnet_c_id
  vpc_security_group_ids = [module.vpc.postgresql_sg_id]
  associate_public_ip_address = false
  key_name = aws_key_pair.backend_key.key_name
  tags = {
    Name = "hauke-instance-c"
    Tier = "private"
  }
}
