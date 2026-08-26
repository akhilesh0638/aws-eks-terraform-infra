##########################################
#   Provider / Region Variables
###########################################
variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

###########################################
#   VPC Variables
###########################################
variable "vpc-cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "cidr-block" {
  description = "CIDR blocks for the 6 subnets (2 public web, 2 private app, 2 private DB)"
  type        = list(string)
}

variable "az" {
  description = "Availability zones used for the VPC subnets"
  type        = list(string)
}

variable "rtb-cidr" {
  description = "Destination CIDR for public/private route table default routes"
  type        = string
}

variable "eip-domain" {
  description = "Domain type for the Elastic IP used by the NAT Gateway"
  type        = string
}

###########################################
#   Security Group Variables
###########################################
variable "sg-name" {
  description = "Name of the web security group"
  type        = string
}

variable "for-each" {
  description = "List of ports to open on the web security group"
  type        = list(number)
}

variable "protocol" {
  description = "Protocol used for the ingress rules"
  type        = string
}

variable "ipv4-cidr" {
  description = "IPv4 CIDR allowed for ingress/egress"
  type        = list(string)
}

variable "ipv6-cidr" {
  description = "IPv6 CIDR allowed for egress"
  type        = list(string)
}

variable "egress-protocol" {
  description = "Protocol used for the egress rule (-1 = all)"
  type        = string
}

#######################
### eks
########################
variable "cluster_name" {
  type = string
}


##################
## IAM
#################
variable "eks_cluster_role" {
  type = string
}

variable "eks_node_role" {
  type = string
}

##################
#   RDS
##################
variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}



