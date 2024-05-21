module "documentdb_cluster" {
  source = "cloudposse/documentdb-cluster/aws"

  name            = "fastfood-documentdb"
  cluster_size    = 2
  master_username = "fastfood"
  master_password = "Fiap2024!"
  instance_class  = "db.t3.medium"
  vpc_id          = aws_vpc.main.id
  subnet_ids      = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.public-us-east-1a.id,
    aws_subnet.private-us-east-1b.id,
    aws_subnet.public-us-east-1b.id
  ]
  #allowed_security_groups = ["sg-xxxxxxxx"]
  #zone_id                 = "Zxxxxxxxx"
}