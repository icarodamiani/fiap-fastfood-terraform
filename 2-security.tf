# Security group for public subnet resources
resource "aws_security_group" "public" {
  name   = "public-pg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-pg"
  }
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "sg_ingress_public_443" {
  security_group_id = aws_security_group.public.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg_ingress_public_80" {
  security_group_id = aws_security_group.public.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

## Egress rule
resource "aws_security_group_rule" "sg_egress_public" {
  security_group_id = aws_security_group.public.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for data plane
resource "aws_security_group" "data_plane_sg" {
  name   = "fiap-t4-sg-dp"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "fiap-t4-sg-dp"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "fiap-t4-sg-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "fiap-t4-sg-nodes"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "nodes" {
  description       = "Allow nodes to communicate with each other"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
}

resource "aws_security_group_rule" "nodes_inbound" {
  description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = flatten([var.private_subnet_cidr_blocks])
}

## Egress rule
resource "aws_security_group_rule" "node_outbound" {
  security_group_id = aws_security_group.data_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for control plane
resource "aws_security_group" "control_plane_sg" {
  name   = "fiap-t4-sg-cp"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "fiap-t4-sg-cp"
  }
}

# Security group traffic rules
## Ingress rule
resource "aws_security_group_rule" "control_plane_inbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = flatten([var.private_subnet_cidr_blocks, var.public_subnet_cidr_blocks])
}

## Egress rule
resource "aws_security_group_rule" "control_plane_outbound" {
  security_group_id = aws_security_group.control_plane_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}