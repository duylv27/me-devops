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
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  intra_subnets   = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

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
  intra_subnets   = local.intra_subnets

  # create nat gateways
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # enable dns hostnames and support
  enable_dns_hostnames = true
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

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}


###########################################################################################
# EKS
###########################################################################################
module "eks" {
  # invoke public eks module
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  # eks cluster name and version
  cluster_name    = var.eks_cluster_name
  cluster_version = var.k8s_version

  # vpc & subnet
  vpc_id                    = module.vpc_and_subnets.vpc_id
  subnet_ids                = module.vpc_and_subnets.private_subnets
  control_plane_subnet_ids  = module.vpc_and_subnets.intra_subnets

  # to enable public and private access for eks cluster endpoint
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # create an OpenID Connect Provider for EKS to enable IRSA
  enable_irsa = true

  # install eks managed addons
  # more details are here - https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
  cluster_addons = {
    # extensible DNS server that can serve as the Kubernetes cluster DNS
    coredns = {
      preserve    = true
      most_recent = true
    }

    # maintains network rules on each Amazon EC2 node. It enables network communication to your Pods
    kube-proxy = {
      most_recent = true
    }

    # a Kubernetes container network interface (CNI) plugin that provides native VPC networking for your cluster
    vpc-cni = {
      most_recent = true
    }
  }

  # eks managed node group named worker
  eks_managed_node_groups = var.workers_config

}

# EC2 instance
resource "aws_instance" "my_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = module.vpc_and_subnets.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name = "my-ec2-instance"
  }
}