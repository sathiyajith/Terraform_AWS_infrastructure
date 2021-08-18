provider "aws" {
  profile = "default"
  region  =  "us-west-2"
}


resource "aws_s3_bucket" "prod_learning_tf" {
  bucket = "learning-tf-17082021"
  acl    = "private"
}

resource "aws_vpc_default" "default" {}
