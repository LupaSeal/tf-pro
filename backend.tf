terraform {
  backend "s3" {
    bucket         = "tf-pro-cert-bucket-9cefvxxgs8"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-pro-cert-lock-yq3od59wmo"
  }
}
