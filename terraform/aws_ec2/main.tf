provider "aws" {
    region = "us-east-1"
    #The account is default aws cli!
}

    # v p c    
resource "aws_vpc" "vpc_app_ezops" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name               = "vpc_app_ezops"
    Managedby          = "Terraform"
  }
}


    # subnet
resource "aws_subnet" "sub_pub_app_ezops" {
  vpc_id                  = aws_vpc.vpc_app_ezops.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name       = "sub_pub_app_ezops_1a"
    Managedby  = "Terraform"
  }
}

    # subnet
resource "aws_subnet" "sub_private_app_ezops" {
  vpc_id       = aws_vpc.vpc_app_ezops.id
  cidr_block   = "10.0.128.0/24"
  
  tags = {
    Name       = "sub_private_app_ezops_2b"
    Managedby  = "Terraform"
  }
}

resource "aws_internet_gateway" "igw_app_ezops" {
  vpc_id = aws_vpc.vpc_app_ezops.id


  tags = {
    Name       = "igw_app_ezops"
    Managedby  = "Terraform"
  }

}

    # route table
resource "aws_route_table" "rtb_app_ezops" {
  vpc_id       = aws_vpc.vpc_app_ezops.id

  tags = {
    Name       = "rtb_app_ezops"
    Managedby  = "Terraform"
  }
}

resource "aws_route" "routes_app_ezops" {
  route_table_id         = aws_route_table.rtb_app_ezops.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_app_ezops.id
}

resource "aws_route_table_association" "rtb_association_pub" {
  subnet_id       = aws_subnet.sub_pub_app_ezops.id
  route_table_id  = aws_route_table.rtb_app_ezops.id
}

resource "aws_route_table_association" "rtb_association_private" {
  subnet_id       = aws_subnet.sub_private_app_ezops.id
  route_table_id  = aws_route_table.rtb_app_ezops.id
}
    
    # SECURITY GROUP *is default :
        # ---> If it doesn't work, "port 22: Resource temporarily unavailable" remove the default sg and create a new route with port 22 and ip in the security group <---



    # instance
resource "aws_instance" "ec2_app_ezops" {
    ami                         = "ami-0149b2da6ceec4bb0"
    instance_type               = "t2.micro"
    key_name                    = "app_ezops"
    subnet_id                   = aws_subnet.sub_pub_app_ezops.id
    associate_public_ip_address = true
    
    tags = {
        Name	    = "ec2_app_ezops"
        Managedby   = "Terraform"
        Repository  = "GitHub - ezops-test-nicolas"
        Owner	    = "nicolas.pereira"
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
        Repository            = "GitHub - ezops-test-nicolas"
        Owner	              = "nicolas.pereira"
    }        
  }
}

# end!
