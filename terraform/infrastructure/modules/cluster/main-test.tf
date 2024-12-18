provider "aws" {
  region = var.aws_region
}

# to retrieve the availability zones
data "aws_availability_zones" "available" {}

locals {
  # newbits is the new mask for the subnet, which means it will divide the VPC into 256 (2^(32-24)) subnets.
  newbits = 8

  # netcount is the number of subnets that we need, which is 6 in this case
  netcount = 6

  # cidrsubnet function is used to divide the VPC CIDR block into multiple subnets
  all_subnets = [for i in range(local.netcount) : cidrsubnet(var.vpc_cidr, local.newbits, i)]

  # we create 3 public subnets and 3 private subnets using these subnet CIDRs
  public_subnets  = slice(local.all_subnets, 0, 3)
  private_subnets = slice(local.all_subnets, 3, 6)

}

# vpc module to create vpc, subnets, NATs, IGW etc..
module "vpc_and_subnets" {
  # invoke public vpc module
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  # vpc name
  name = var.vpc_name

  # availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # vpc cidr
  cidr = var.vpc_cidr

  # public and private subnets
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  # create nat gateways
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # enable dns hostnames and support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # tags for public, private subnets and vpc
  tags                = var.tags
  public_subnet_tags  = var.additional_public_subnet_tags
  private_subnet_tags = var.additional_private_subnet_tags

  # create internet gateway
  create_igw       = var.create_igw
  instance_tenancy = var.instance_tenancy

}

# Security Group
resource "aws_security_group" "ec2_sg" {
  vpc_id      = module.vpc_and_subnets.vpc_id
  description = "Security Group for EC2"
  name        = "ec2_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_cidr]
  }

  tags = {
    Name = "allow-ssh"
  }
}

# EC2 instance
resource "aws_instance" "my_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc_and_subnets.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "my-ec2-instance"
  }
}