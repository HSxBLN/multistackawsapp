resource "aws_s3_bucket" "terraform_state" {
  bucket = "hauke-ironhack-lab1-state-bucket-neu"
  region = var.aws_region

  tags = {
    Name        = "Terraform State Bucket"
    Project     = "ironhack-lab1-Hauke"
}
}
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "hauke-ih-lab1-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  region       = var.aws_region

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "Terraform State Lock Table Hauke"
    Project = "ironhack-lab1"
  }
}
terraform {
  backend "s3" {
    bucket         = "hauke-ironhack-lab1-state-bucket-neu"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "hauke-ih-lab1-state-lock"
    encrypt        = true
  }
}
output "backend_config" {
  description = "Configuration for the Terraform backend"
  value = {
    s3_bucket         = aws_s3_bucket.terraform_state.bucket
    dynamodb_table    = aws_dynamodb_table.terraform_state_lock.name
    region            = var.aws_region
    key              = "terraform.tfstate"
    Enabled           = true
    use_lockfile      = true 
  }
}