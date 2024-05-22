resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      element(concat(aws_subnet.private.*.id, [""]), 0),
      element(concat(aws_subnet.private.*.id, [""]), 1),
      element(concat(aws_subnet.public.*.id, [""]), 0),
      element(concat(aws_subnet.public.*.id, [""]), 1)
    ]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon-eks-cluster-policy
  ]
}

resource "aws_security_group" "eks" {
  name        = "${var.cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}

resource "aws_security_group_rule" "cluster_inbound_all" {
  description       = "Allow cluster API Server to communicate with the worker nodes"
  to_port           = 0
  from_port         = 0
  protocol          = "all"
  security_group_id = aws_security_group.eks.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound_all" {
  to_port           = 0
  from_port         = 0
  protocol          = "all"
  security_group_id = aws_security_group.eks.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
}


resource "aws_iam_role" "eks-cluster-role" {
  name = "fiap-t4-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role" "eks-pods-role" {
  name = "fiap-t4-pods-role"

  assume_role_policy = templatefile("role-template.json", {
    OIDC_ARN        = aws_iam_openid_connect_provider.cluster.arn,
    OIDC_ID         = replace(aws_eks_cluster.cluster.identity.0.oidc.0.issuer, "https://", "")
    NAMESPACE       = "default",
    SERVICE_ACCOUNT = "default-service-account"
  })
}

resource "aws_iam_role_policy_attachment" "amazon-sqs-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role       = aws_iam_role.eks-pods-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-cognito-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
  role       = aws_iam_role.eks-pods-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-documentdb-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBReadOnlyAccess"
  role       = aws_iam_role.eks-pods-role.name
}


data "tls_certificate" "cluster_certificate" {
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_certificate.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}