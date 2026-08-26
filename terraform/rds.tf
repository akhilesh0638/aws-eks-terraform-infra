##################################################
#   RDS-SG
##################################################
resource "aws_security_group" "rds-sg" {
  name        = "RDS-SG"
  description = "Security group for ecommerce RDS MySQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL from EKS nodes"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

##################################################
#   Database Subnet Group
##################################################
resource "aws_db_subnet_group" "subnet-group" {
  name       = "rdssubnetgroup"
  subnet_ids = [aws_subnet.app-private-subnet-1.id, aws_subnet.app-private-subnet-2.id]

  tags = {
    Name = "subnet-group"
  }
}


##################################################
#   MySQL Database
##################################################
resource "aws_db_instance" "rdsdb" {
  allocated_storage      = 30
  max_allocated_storage  = 50
  storage_type           = "gp3"
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  port                   = 3306
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnet-group.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]

  tags = {
    Name = "rdsdb"
  }
}