variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "vnetcidr" {
  default     = "10.0.0.0/16"
}

variable "subnetcidr" {
  default     = "10.0.0.0/24"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# ubuntu-trusty-20.04 (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-0dd76f917833aac4b"
    "us-west-2" = "ami-7f675e4f"
  }
}
