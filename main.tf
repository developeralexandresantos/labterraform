terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}

# Provedor AWS apontando para LocalStack
provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "sa-east-1"

  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

# Criação da VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name     = "main-vpc"
    Ambiente = "local"
  }
}

# Sub-rede da VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  # OBS: LocalStack não simula availability zones. Este campo pode ser omitido.
  # availability_zone = "sa-east-1a"

  tags = {
    Name     = "main-subnet"
    Ambiente = "local"
  }
}

# Internet Gateway para permitir acesso externo
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name     = "main-igw"
    Ambiente = "local"
  }
}

# Tabela de rotas para acessar internet via o IGW
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name     = "main-route-table"
    Ambiente = "local"
  }
}

# Associação da subnet com a route table
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Par de chaves públicas (valor fictício para testes locais)
# resource "aws_key_pair" "main" {
#   key_name   = "main-key"

#   # Usando chave dummy para evitar erro no LocalStack
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtestkeyforlocalstackonly user@local"

#   tags = {
#     Name     = "main-key"
#     Ambiente = "local"
#   }
# }

# Grupo de segurança (libera SSH e HTTP para qualquer IP)
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "main-security-group"
    Ambiente = "local"
  }
}

# OBS: Instância EC2 está comentada porque o LocalStack não suporta EC2 real
# resource "aws_instance" "main" {
#   ami           = "ami-0c55b159cbfafe1f0"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.main.id
#   key_name      = aws_key_pair.main.key_name
#   security_groups = [aws_security_group.main.name]

#   tags = {
#     Name     = "main-instance"
#     Ambiente = "local"
#   }
# }
