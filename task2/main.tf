terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = var.aws_profile
}

variable "aws_profile" {
  type = string
  default = "personal"
}

data "aws_ami" "ubuntu_task2" {

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240927"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "amazon-linux-task2" {

  filter {
    name = "name"
    values = ["al2023-ami-2023.5.20241001.1-kernel-6.1-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_instance" "ubuntu_server" {
  ami           = data.aws_ami.ubuntu_task2.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]

  tags = {
    Name = "ubuntu-task2"
  }

  # user_data = <<-EOF
  #             #!/bin/bash
  #             apt update
  #             apt install -y nginx
  #             echo "<h1>Hello World</h1>" > /var/www/html/index.html
  #             echo "<p>OS Version: $(lsb_release -d | cut -f2)</p>" >> /var/www/html/index.html
  #             systemctl start nginx
  #             EOF

  user_data = <<-EOF
              #!/bin/bash
              # Install Docker according manual https://docs.docker.com/engine/install/ubuntu/#installation-methods
              # Add Docker's official GPG key:
              apt-get update
              apt-get install -y ca-certificates curl
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc
              # Add the repository to Apt sources:
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee  /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              # Start docker
              systemctl enable docker
              systemctl start docker
              # create custom index page for nginx server
              mkdir ~/nginx-hello
              cd ~/nginx-hello
              cat <<EOL > index.html
              <html>
              <body>
              <h1>Hello World</h1>
              <p>OS Version: $(lsb_release -a)</p>
              </body>
              </html>
              EOL
              # Create Dockerfile with nginx server and custom index page
              cat <<EOL > Dockerfile
              FROM nginx:alpine
              COPY ./index.html /usr/share/nginx/html/index.html
              EOL
              cat <<EOL > Dockerfile
              FROM nginx:alpine
              COPY ./index.html /usr/share/nginx/html/index.html
              EOL
              # build docker image
              docker build -t nginx-hello .
              # create and run new container from nginx-hello image
              docker run -p 80:80 -d nginx-hello
              EOF

  user_data_replace_on_change = true
}

resource "aws_security_group" "ubuntu_sg" {
  name = "ubuntu-sg"
  tags = {
    Name = "ubuntu-sg"
  }
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "ubuntu_allowed_egress_rule" {
  security_group_id = aws_security_group.ubuntu_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ubuntu_ingress_tcp80" {
  security_group_id = aws_security_group.ubuntu_sg.id
  description = "Allow Port 80:80 tcp ingress"
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ubuntu_ingress_tcp22" {
  security_group_id = aws_security_group.ubuntu_sg.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ubuntu_ingress_tcp443" {
  security_group_id = aws_security_group.ubuntu_sg.id
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ubuntu_ingress_icmp" {
  security_group_id = aws_security_group.ubuntu_sg.id
  ip_protocol = "icmp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = -1
  to_port = -1
}

resource "aws_instance" "amazon_linux_server" {
  ami           = data.aws_ami.amazon-linux-task2.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.amazon_linux_sg.id]

  tags = {
    Name = "amazon-linux-task2"
  }
}

resource "aws_security_group" "amazon_linux_sg" {
  name = "amazon_linux_sg-sg"
  tags = {
    Name = "amazon_linux_sg-sg"
  }
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "amazon_linux_ingress_icmp" {
  security_group_id = aws_security_group.amazon_linux_sg.id
  ip_protocol = "icmp"
  cidr_ipv4 = aws_default_vpc.default_vpc.cidr_block
  from_port = -1
  to_port = -1
  tags = {
    Name = "amazon-linux-sg-ingress_icmp"
  }
}

resource "aws_vpc_security_group_egress_rule" "amazon_linux_allowed_egress_rule" {
  security_group_id = aws_security_group.amazon_linux_sg.id
  ip_protocol = "-1"
  cidr_ipv4 = aws_default_vpc.default_vpc.cidr_block
  tags = {
    Name = "amazon-linux-sg-egress_all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "amazon_linux_ingress_tcp80" {
  security_group_id = aws_security_group.amazon_linux_sg.id
  description = "Allow Port 80:80 tcp ingress"
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = aws_default_vpc.default_vpc.cidr_block
  tags = {
    Name = "amazon_linux_ingress_tcp80"
  }
}

resource "aws_vpc_security_group_ingress_rule" "amazon_linux_ingress_tcp22" {
  security_group_id = aws_security_group.amazon_linux_sg.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_ipv4 = aws_default_vpc.default_vpc.cidr_block
  tags = {
    Name = "amazon_linux_ingress_tcp22"
  }
}

resource "aws_vpc_security_group_ingress_rule" "amazon_linux_ingress_tcp443" {
  security_group_id = aws_security_group.amazon_linux_sg.id
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_ipv4 = aws_default_vpc.default_vpc.cidr_block
  tags = {
    Name = "amazon-linux-sg-ingress-tcp443"
  }
}