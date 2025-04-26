

**`provider.tf`**

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a recent stable version
    }
  }
  required_version = ">= 1.0"

  # --- OPTIONAL: S3 Remote State Backend (Recommended for Production/Teams) ---
  # Ensure you create the S3 bucket and optional DynamoDB table FIRST.
  # backend "s3" {
  #   bucket         = "your-unique-terraform-state-bucket-name" # <--- REPLACE BUCKET NAME
  #   key            = "global/s3/terraform.tfstate" # Example path within the bucket
  #   region         = "us-east-1"                   # <--- REPLACE BUCKET REGION
  #   encrypt        = true
  #   # dynamodb_table = "your-terraform-lock-table" # Optional: for state locking - <--- REPLACE TABLE NAME
  # }
}

provider "aws" {
  region = var.aws_region
}

# Get available Availability Zones in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
