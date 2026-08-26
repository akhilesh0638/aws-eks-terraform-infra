#######################################
# VPC Outputs
#######################################
output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "web_public_subnet_1_id" {
  value = aws_subnet.web-public-subnet-1.id
}

output "web_public_subnet_2_id" {
  value = aws_subnet.web-public-subnet-2.id
}

output "app_private_subnet_1_id" {
  value = aws_subnet.app-private-subnet-1.id
}

output "app_private_subnet_2_id" {
  value = aws_subnet.app-private-subnet-2.id
}


output "public_route_table_id" {
  value = aws_route_table.public-rtb.id
}

output "private_route_table_id" {
  value = aws_route_table.private-rtb.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.project-NAT.id
}

#######################################
# Security Outputs
#######################################
output "web_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}
#######################################
# eks
#######################################
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}
output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}
output "node_group_name" {
  value = aws_eks_node_group.nodes.node_group_name
}

##################################
#    RDS
##################################
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.rdsdb.endpoint
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.rdsdb.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.rdsdb.db_name
}