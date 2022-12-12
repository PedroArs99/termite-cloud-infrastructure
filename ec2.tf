resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssb"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_network_interface" "nic" {
  subnet_id   = aws_subnet.subnet.id
  private_ips = ["172.16.10.100"]

  security_groups = [ "value" ]

  tags = {
    Name = var.name
  }
}

resource "aws_instance" "ec2" {
  ami           = "ami-087924c9e0410af37" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type = "t4g.micro"

  network_interface {
    network_interface_id = aws_network_interface.nic.id
    device_index         = 0
  }

  root_block_device {
    delete_on_termination = true
    iops                  = 3000
    volume_size           = 10
    volume_type           = "gp3"

    tags = {
      Name = var.name
    }
  }

  tags = {
    Name = var.name
  }

}
