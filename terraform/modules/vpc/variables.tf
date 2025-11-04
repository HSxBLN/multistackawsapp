variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for the public subnet (Instance A)"
  type        = string
  default     = "10.2.1.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private subnet B (Instance B - Redis/Worker)"
  type        = string
  default     = "10.2.2.0/24"
}

variable "private_subnet_c_cidr" {
  description = "CIDR block for private subnet C (Instance C - PostgreSQL)"
  type        = string
  default     = "10.2.3.0/24"
}

variable "az_public_a" {
  description = "Availability Zone for public subnet"
  type        = string
  default     = "us-west-2a"
}

variable "az_private_b" {
  description = "Availability Zone for private subnet B"
  type        = string
  default     = "us-west-2b"
}

variable "az_private_c" {
  description = "Availability Zone for private subnet C"
  type        = string
  default     = "us-west-2c"
}
