resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-${var.cluster_name}"

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
  name = "eks-role-${var.cluster_name}"

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

resource "aws_eks_cluster" "cluster" {
  name                      = var.cluster_name
  version                   = var.cluster_version
  role_arn                  = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1b.id
    ]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon-eks-cluster-policy
  ]
}

data "tls_certificate" "cluster_certificate" {
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_certificate.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}