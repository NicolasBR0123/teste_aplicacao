

provider "aws" {
    region = "us-east-1"
    #The account is default aws cli!
}

    # v p c    
resource "aws_vpc" "vpc_app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name               = "vpc_app"
    Managedby          = "Terraform"
  }
}

    # security is default
resource "aws_default_security_group" "sg_app" {
  vpc_id = aws_vpc.vpc_app.id

  
  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "sg_app"
  }
}

    # subnet public
resource "aws_subnet" "aplication_sub_pub_1a" {
  vpc_id                  = aws_vpc.vpc_app.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name"       = "${local.aplication_sub_pub_1a}"
    Managedby  = "Terraform"
  }
}

    # subnet private
resource "aws_subnet" "aplication_sub_priv_2b" {
  vpc_id       = aws_vpc.vpc_app.id
  cidr_block   = "10.0.128.0/24"
  
  tags = {
    "Name"       = "${local.aplication_sub_priv_2b}"
    Managedby  = "Terraform"
  }
}

resource "aws_internet_gateway" "igw_app" {
  vpc_id = aws_vpc.vpc_app.id


  tags = {
    Name       = "igw_app"
    Managedby  = "Terraform"
  }

}

    # route table
resource "aws_route_table" "route_table_app" {
  vpc_id       = aws_vpc.vpc_app.id
  
  tags = {
    Name       = "route_table_app"
    Managedby  = "Terraform"
  }
}

resource "aws_route" "routes_app" {
  route_table_id         = aws_route_table.route_table_app.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_app.id
}

resource "aws_route_table_association" "rtb_association_pub" {
  subnet_id       = aws_subnet.aplication_sub_pub_1a.id
  route_table_id  = aws_route_table.route_table_app.id
}

resource "aws_route_table_association" "rtb_association_private" {
  subnet_id       = aws_subnet.aplication_sub_priv_2b.id
  route_table_id  = aws_route_table.route_table_app.id
}
    

    # instance
resource "aws_instance" "Ec2_app_ezops" {
    ami                         = "ami-0149b2da6ceec4bb0"
    instance_type               = "t2.micro"
    key_name                    = "app_ezops"
    subnet_id                   = aws_subnet.aplication_sub_pub_1a.id
    associate_public_ip_address = true 

    tags = {
        Name	                = "ec2_app_ezops"
        Managedby               = "Terraform"
        Repository              = "GitHub - ezops-test-nicolas.pereira"
        Owner	                = "nicolas.pereira"
    }

    # root disk
    root_block_device {
        volume_size           = "20"
        volume_type           = "gp2"
        encrypted             = true
        delete_on_termination = true

    tags = {
        Name	              = "vol_root_ec2_app_ezops"
        Managedby             = "Terraform"
        Repository            = "GitHub - ezops-test-nicolas.pereira"
        Owner	              = "nicolas.pereira"
    }        
  }
}

# end!
