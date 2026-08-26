# =====================================
# EKS Cluster
# =====================================
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.35"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.app-private-subnet-1[*].id,
      aws_subnet.app-private-subnet-1[*].id,
      aws_subnet.web-public-subnet-1[*].id,
      aws_subnet.web-public-subnet-2[*].id
    )

    security_group_ids = [
      aws_security_group.eks_cluster_sg.id
    ]

    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = var.cluster_name
  }
}

# =====================================
# EKS Managed Node Group
# =====================================

resource "aws_eks_node_group" "nodes" {
  cluster_name = aws_eks_cluster.eks.name

  node_group_name = "devops-node-group"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = concat(
    aws_subnet.app-private-subnet-1[*].id,
    aws_subnet.app-private-subnet-2[*].id
  )

  instance_types = [
    "t2.large"
  ]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]

  tags = {
    Name = "devops-node-group"
  }
}