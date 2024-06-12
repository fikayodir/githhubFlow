terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
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