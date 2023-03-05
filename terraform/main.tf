

provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIA5KYAAUJJEMF5D4JJ"
  secret_key = "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"
}

# data "aws_ami" "app_ami" {
#   most_recent = true
#   owners      = ["amazon"]


#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

# resource "aws_instance" "instance-1" {
#   ami           = data.aws_ami.app_ami.id
#   instance_type = "t2.micro"
# }

resource "aws_ecr_repository" "ecr-oltur-terraform" {
  name                 = "oltur-terraform"

  # image_scanning_configuration {
  #   scan_on_push = true
  # }
}