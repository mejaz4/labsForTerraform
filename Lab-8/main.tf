provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "my_server_web" {
  ami                    = "ami-088e71edb8795252f"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  tags = {
    Name = "EC2-Server-Web"
  }
  depends_on = [aws_instance.my_server_db, aws_instance.my_server_app]
}

resource "aws_instance" "my_server_app" {
  ami                    = "ami-088e71edb8795252f"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  tags = {
    Name = "EC2-Server-App"
  }
  depends_on = [aws_instance.my_server_db]
}

resource "aws_instance" "my_server_db" {
  ami                    = "ami-088e71edb8795252f"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  tags = {
    Name = "EC2-Server-DB"
  }
}

resource "aws_security_group" "general" {
  name = "My Security Groud"
  dynamic "ingress" {

    for_each = ["80", "443", "22", "3389"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My Security Group"
  }
}

//output

output "my_security_group_id" {
  value = aws_security_group.general.id
}

output "my_security_group_arn" {
  value = aws_security_group.general
}

