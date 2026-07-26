terraform {
  backend "s3" {
    bucket         = "tf-state-aws-bucket01"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}