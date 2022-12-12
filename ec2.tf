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
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
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

  security_groups = [ aws_security_group.allow_ssh.id ]

  tags = {
    Name = var.name
  }
}

resource "aws_key_pair" "root" {
  key_name = "termite-cloud-infrastructure-root-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJawwzGWklAOyrVWO46zAXbA6V9lhGf6lS9Hz+6uDjYyuNNcPqIfBTj5mSEFDcpTtUDiYe5msaAA9k4rAmbQOh1MQB+E0R8SHbI/K5StXI1aI2JYSKMOJOLyaK2JlBKYe4dTH9rKr61h7KkcVI+HuIvnB92gtkoxDLDxGiWqv5BB/EQ1gEF4T0KkwYqxrdNdrXBRXvAgFm7Iripqs1+9u5Di02MNnkPyCyZefhHYakQZ/FT/pXOQP4lRevOi9z3/JZ8ULp6vub9jqXh/bmUVrUhqtsc4IjTs7Ezy8SHqg8ka0ikfhzuMqp9VHJpDhGv0HAVOuzNqAHBxDm2oBi7yu5c9oLP3kDQJvKBt347NGRxbrx3KPtS5Zox4A6qjGAZ2rb7saC49pTf2EyY8CrlaNUfOa9lddH+kComKonhv48/MJq6VXQtX+zJCVLamoCEfIlylTfRRdcZiuGXQD53hH8o5J8AT8hefd8DLzh4J/zU4EIFYJXqLelXuZ5t8drEUU= pedroars@MacBook-Pro-de-Pedro.local"
}

resource "aws_instance" "ec2" {
  ami           = "ami-087924c9e0410af37" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  instance_type = "t4g.micro"
  key_name = aws_key_pair.root.key_name

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
