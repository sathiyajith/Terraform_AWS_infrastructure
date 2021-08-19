variable "whitelist" {
  type = list(string)
}

variable "web_image_id" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "web_min_size" {
  type = number
}

variable "web_max_size" {
  type = number
}

provider "aws" {
  profile = "default"
  region  =  "us-east-2"
}


resource "aws_s3_bucket" "prod_learning_tf" {
  bucket = "learning-tf-17082021"
  acl    = "private"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-2a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-2b"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "prod_web" {
  name = "prod_web"
  description = "Allow standard http and https ports inbound and everything outbound"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.whitelist
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = var.whitelist
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = var.whitelist
  }

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_launch_template" "prod_web" {
  name_prefix = "prod-web"
  image_id = var.web_image_id
  instance_type = var.web_instance_type
   tags = {
     "Terraform" : "true"
   }

}

resource "aws_autoscaling_group" "prod_web" {
  min_size = var.web_min_size
  max_size = var.web_max_size
  vpc_zone_identifier = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]

  launch_template {
    id = aws_launch_template.prod_web.id
  }

  tag{
    key = "Terraform"
    value = "true"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb = aws_elb.prod_web.id
}



resource "aws_elb" "prod_web" {
  name = "prod-web"
  subnets = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.prod_web.id]
  
  tags = {
    "Terraform" : "true"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}


