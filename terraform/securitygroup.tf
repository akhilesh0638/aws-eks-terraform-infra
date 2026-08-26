###############################################
#   Web Security Group
###############################################
resource "aws_security_group" "eks_cluster_sg" {
  name   = var.sg-name
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.for-each

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.protocol
      cidr_blocks = var.ipv4-cidr
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = var.egress-protocol
    cidr_blocks      = var.ipv4-cidr
    ipv6_cidr_blocks = var.ipv6-cidr
  }

  tags = {
    Name = "eks_cluster_sg"
  }
}