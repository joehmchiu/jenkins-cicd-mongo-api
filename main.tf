terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "default" {
  cidr_block           = var.vnetcidr
  enable_dns_hostnames = true

  tags = {
    Name = "tf_mongo"
  }
}

resource "aws_subnet" "tf_mongo_subnet" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.subnetcidr
  map_public_ip_on_launch = true

  tags = {
    Name = "tf_mongo_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "tf_mongo_ig"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "aws_route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf_mongo_subnet.id
  route_table_id = aws_route_table.r.id
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "instance_sg"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "default" {
  template = file("${path.module}/scripts/temp.sh")
  vars = {
    hello = "Hello"
    world = "world"
  }
}

resource "aws_instance" "api" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  ami = var.aws_amis[var.aws_region]

  key_name = var.key_name

  # The security group allow 8600 and SSH access
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id              = aws_subnet.tf_mongo_subnet.id
  # user_data              = file("userdata.sh")

  provisioner "file" {
    source      = "scripts/api.py"
    destination = "/tmp/api.py"
  }

  provisioner "file" {
    source      = "scripts/Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "file" {
    source      = "scripts/docker-mongo.sh"
    destination = "/tmp/docker-mongo.sh"
  }

  provisioner "file" {
    source      = "scripts/start.sh"
    destination = "/tmp/start.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("/etc/keys/ssh-key01.key")}"
    host        = "${self.public_dns}"
  }

  user_data = data.template_file.default.rendered

  # Instance tags
  tags = {
    Name = "mongo-api"
  }
}

locals {
  tempfile = templatefile("${path.module}/scripts/ssh-config.tpl", {
    ip = "${aws_instance.api.public_ip}"
  })
}

resource "local_file" "ssh" {
  content = local.tempfile
  filename = "${path.module}/scripts/ssh-config.yml"

  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/scripts/ssh-config.yml"
  }
}

