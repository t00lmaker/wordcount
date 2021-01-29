resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "Terraform VPC"
    }
}

resource "aws_subnet" "pub_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.1.0/24"

    map_public_ip_on_launch = true
}

resource "aws_subnet" "priv_subnet1" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-east-1d"
}

resource "aws_subnet" "priv_subnet2" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "us-east-1f"
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "public_rt_association" {
    subnet_id      = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private1_rt_association" {
    subnet_id      = aws_subnet.priv_subnet1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2_rt_association" {
    subnet_id      = aws_subnet.priv_subnet2.id
    route_table_id = aws_route_table.private_rt.id
}