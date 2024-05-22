resource "aws_docdb_subnet_group" "group" {
  name       = "fiap-t4-docdb"
  subnet_ids = [
    element(concat(aws_subnet.private.*.id, [""]), 0),
    element(concat(aws_subnet.private.*.id, [""]), 1),
    element(concat(aws_subnet.public.*.id, [""]), 0),
    element(concat(aws_subnet.public.*.id, [""]), 1)
  ]
}

resource "aws_docdb_cluster_instance" "instance" {
  count              = 1
  identifier         = "fiap-t4-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.cluster.id
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster" "cluster" {
  skip_final_snapshot             = true
  db_subnet_group_name            = aws_docdb_subnet_group.group.name
  cluster_identifier              = "fiap-t4-docdb-cluster"
  engine                          = "docdb"
  master_username                 = "fastfood"
  master_password                 = "Fiap2024!"
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.params.name
  vpc_security_group_ids          = [aws_security_group.docdb.id]
}

resource "aws_docdb_cluster_parameter_group" "params" {
  family = "docdb5.0"
  name   = "fiap-t4-docdb-params"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

# Security group for public subnet resources
resource "aws_security_group" "docdb" {
  name   = "fiap-t4-sg-docdb"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "fiap-t4-sg-docdb"
  }
}


resource "aws_security_group_rule" "docdb_ingress" {
  security_group_id = aws_security_group.docdb.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "docdb_egress" {
  security_group_id = aws_security_group.docdb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}