resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "tch_rt_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.main_rt.id
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
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "allow_k3s" {
  name        = "allow_k3s"
  description = "Allow K3S inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "K3S from the internet"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_k3s"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTPS from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_k3s"
  }
}

resource "aws_network_interface" "nic" {
  subnet_id   = aws_subnet.subnet.id
  private_ips = ["172.16.10.100"]

  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_k3s.id, aws_security_group.allow_http.id, aws_security_group.allow_https.id]

  tags = {
    Name = var.name
  }
}

resource "aws_key_pair" "root" {
  key_name   = "termite-cloud-infrastructure-root-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCc5ljHZepZuzwyQs08eOg30KJLzH1M9n8LCk61M2GDKxXqAM3fQbFup21SbR//1pdVwlJNqDB8jKCYspN0sgdL0OZkdfI+5nesOq1A7DvqFsm+BeO+ddTDBHML1ja2rJxW37N5uzlGCCYEV87/0UyIUApPNm4O1WSabrLg5TAy/QH3zEX6PPxGpDUE16hjx8VAvnCpoidG4sflipbJ22nqcRvzB00c8ONhX5IO+WpoIXejwZRiA+yoWnYodzDp55oy6B7/nUMSnIqC/yHkwBHRavb7MAqZL1e2szpR8aalF8U1CSEC0hI4mgMjXjn57y+DiOJru7ig6RGEcvVXgdFcgKst8tGIyLVBdkFG5qlqEsqEsApLEvJm+rBnmOEa7siainhKUYwfJoYxBZ4omZKFt23AyP7bt2c0nZnxxBCj7+uiXB8A/zytEQR0BdxuID/piRq8l3rk8n2PjlTB2qOdtieFpOBSUWheW2AQgZ8F1etuKqkM5BSBc+tCWtQ3Us= pedroars@MacBook-Pro-de-Pedro.local"
}

resource "aws_instance" "ec2" {
  ami                  = "ami-087924c9e0410af37" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
  iam_instance_profile = aws_iam_instance_profile.cloud_watch_agent_profile.name
  instance_type        = "t4g.small"
  key_name             = aws_key_pair.root.key_name

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

resource "aws_eip" "ec2_eip" {
  instance = aws_instance.ec2.id
  vpc      = true
}

resource "aws_iam_instance_profile" "cloud_watch_agent_profile" {
  name = "CloudWatchAgentServer"
  role = "CloudWatchAgentServerRole"
}
