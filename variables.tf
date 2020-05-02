variable "region" {
	default = "us-west-2"
}
variable "instance_type" {
  default = "t2.micro"
  description = "The AWS EC2 instance type. Defaults to t2.micro if empty"
}
variable "vpc_cidr_range" {
  description = "The CIDR block (range) for the subnet that will be created. Defaults to 10.0.0.0/16"
  default = "10.0.0.0/16"
}

variable "ami_id" {
	default = "ami-0d1cd67c26f5fca19"
}

locals {
  stack_name = "Presto Swarm"
  cidr_range = var.vpc_cidr_range
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  private_subnets = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.13.0/24",
  ]
}
