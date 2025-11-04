# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "hauke-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hauke-igw"
  }
}
# Elastic IP für NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "-hauke-nat-eip"
  }
}
# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  
  tags = {
    Name = "hauke-nat-gw"
  }
}

# Public Subnet (für Instance A - Frontend/Bastion)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.az_public_a
  map_public_ip_on_launch = true
  
  tags = {
    Name = "hauke-public-subnet"
    Tier = "public"
  }
}

# Private Subnet B (für Instance B - Redis/Worker)
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.az_private_b

  tags = {
    Name = "hauke-private-subnet-b"
    Tier = "private"
  }
}

# Private Subnet C (für Instance C - PostgreSQL)
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_c_cidr
  availability_zone = var.az_private_c
  
  tags = {
    Name = "hauke-private-subnet-c"
    Tier = "private"
  }
}

# Route Table für Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "hauke-public-rt"
  }
}
# Route Table für Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "hauke-private-rt"
  } 
}

# Route Table Association für Public Subnet
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations für Private Subnets
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}

# Eigene Public IP Adresse abfragen
data "http" "my_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Security Group Vote/Result/Bastion Allow 88, 443 from anywhere
resource "aws_security_group" "vote_result_bastion_sg" {
  name        = "hauke-vote-result-bastion-sg"
  description = "Allow 80 and 443 inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
    }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
    Name = "hauke-vote-result-sg"
  }
}

# Security Group Redis/Woker Allow 6379 from Vote/Result SG
resource "aws_security_group" "redis_worker_sg" {
  name        = "hauke-redis-worker-sg"
  description = "Allow 6379 inbound traffic from Vote/Result SG"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.vote_result_bastion_sg.id]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [aws_security_group.vote_result_bastion_sg.id]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [aws_subnet.private_c.cidr_block]
  }
    egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "hauke-redis-worker-sg"
  }
}
# Security Group PostgreSQL Allow 5432 from Redis/Worker SG
resource "aws_security_group" "postgresql_sg" {
  name        = "hauke-postgresql-sg"
  description = "Allow 5432 inbound traffic from Redis/Worker SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.redis_worker_sg.id,aws_security_group.vote_result_bastion_sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22  
    protocol        = "tcp"
    security_groups = [aws_security_group.vote_result_bastion_sg.id]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "hauke-postgresql-sg"
  }
}