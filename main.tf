data "aws_ami" "amzn-linux2" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}






resource "aws_instance" "primus-server" {
  ami           = data.aws_ami.amzn-linux2.id
  instance_type = var.instancetype #"t2.micro"
  key_name      = var.keypair      # "project-key"

  subnet_id                   = aws_subnet.primus-aws_subnet.id
  vpc_security_group_ids      = [aws_security_group.primus-sg.id]
  user_data                   = file ("shellscript.sh")
  user_data_replace_on_change = true


  tags = {
    Name = "HelloWorld"
  }

}


resource "aws_vpc" "primus-vpc" {
  cidr_block           = var.vpc-cidr # "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "prmis-vpc"
  }

}

resource "aws_subnet" "primus-aws_subnet" {
  vpc_id                  = aws_vpc.primus-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.avzone
  map_public_ip_on_launch = true
  tags = {
    Name = "primus-sbn"
  }

}

resource "aws_internet_gateway" "primus-igw" {
  vpc_id = aws_vpc.primus-vpc.id
  tags = {
    Name = "primus-igw"
  }

}


resource "aws_route_table" "primus-rt" {
  vpc_id = aws_vpc.primus-vpc.id

  tags = {
    Name = "primus-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primus-igw.id
  }
}

resource "aws_route_table_association" "primus-table" {
  subnet_id      = aws_subnet.primus-aws_subnet.id
  route_table_id = aws_route_table.primus-rt.id
}



resource "aws_security_group" "primus-sg" {
  name        = "primus-sg"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.primus-vpc.id


  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }




  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #  ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "primus-sg"
  }

}










