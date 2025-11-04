resource "aws_s3_bucket" "terraform_state" {
  bucket = "hauke-ironhack-lab1-state-bucketv2"
  region = var.aws_region

  lifecycle {
    prevent_destroy = true
  }

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
terraform {
  backend "s3" {
    bucket         = "hauke-ironhack-lab1-state-bucketv2"
    key            = "backend/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    use_lockfile   = true
  }
}
output "backend_config" {
  description = "Configuration for the Terraform backend"
  value = {
    s3_bucket         = aws_s3_bucket.terraform_state.bucket
    region            = var.aws_region
    key              = "terraform.tfstate"
    Enabled           = true
    use_lockfile      = true 
  }
}