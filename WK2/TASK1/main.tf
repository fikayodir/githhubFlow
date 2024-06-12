terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

resource "aws_vpc" "faks_vpc" {
    cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.faks_vpc.id

  tags = {
    Name = "Main_Igw"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.faks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = "Public_Route_Table"
  }
  
}

resource "aws_subnet" "Public_subnet" {
  vpc_id = aws_vpc.faks_vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "Public_subnet"
  }
}

resource "aws_security_group" "Faks_Sg" {
  name = "Faks_Sg"
  description =  "Security group  for faks vpc"
  vpc_id = aws_vpc.faks_vpc.id

  tags = {
    name = "Fikayo-SG"
    key ="Faks_Sg" 
  }
  
}

resource "aws_instance" "Vm" {
  ami = "ami-0bb84b8ffd87024d8"
  instance_type = "t3.medium"
  key_name = "FikayoPair"
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
              tar xvfv prometheus*.tar.gz
              sudo mv prometheus-2.52.0.linux-amd64 /opt/prometheus
              EOF
  network_interface {
    network_interface_id = aws_network_interface.ENI.id
    device_index = 0
  }
   provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y git",
      "sudo yum install -y dotnet-sdk-5.0",  # Install .NET SDK
      "git clone https://github.com/fikay/360Rides.git",
      "cd 360Rides",
      "dotnet restore",  # Restore dependencies
      "dotnet publish -c Release -o published",  # Publish the application
      "sudo cp -r published /var/www/360Rides",  # Copy published files to web server directory
      "sudo systemctl restart nginx"  # Restart web server (assuming you're using Nginx)
    ]
  }
  tags = {
    Name = "My_ec2"
  }
}

resource "aws_network_interface" "ENI" {
  subnet_id = aws_subnet.Public_subnet.id
  private_ip = aws_eip.Elastic_ip.public_ip
  security_groups = [aws_security_group.Faks_Sg.id]
    tags = {
      Name = "Public_ec2_eni"
    }
}

resource "aws_eip" "Elastic_ip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
    allocation_id = aws_eip.Elastic_ip.id
  network_interface_id = aws_network_interface.ENI.id
}