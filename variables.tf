# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions

variable "region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "oidc_thumbprint_list" {
  type    = list(any)
  default = []
}

variable "cognito_domain" {
  type    = string
  default = "fastfood-t4-g86"
}

variable "manage_default_network_acl" {
  description = "Should be true to adopt and manage Default Network ACL"
  type        = bool
  default     = false
}

variable "cluster_name" {
  default = "fiap-fastfood-t4-g86"
}

variable "cluster_version" {
  default = "1.27"
}

variable "vpc_docdb_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block range for vpc"
}

variable "private_docdb_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "CIDR block range for the private subnet"
}

variable "public_docdb_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
  description = "CIDR block range for the public subnet"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "192.168.0.0/16"
  description = "CIDR block range for vpc"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["192.168.0.0/24", "192.168.1.0/24"]
  description = "CIDR block range for the private subnet"
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  default     = ["192.168.2.0/24", "192.168.3.0/24"]
  description = "CIDR block range for the public subnet"
}

variable "availability_zones" {
  type  = list(string)
  default = ["us-east-1a", "us-east-1b"]
  description = "List of availability zones for the selected region"
}

variable "node_group_name" {
  description = "Name of the Node Group"
  default = "eks_node_group"
  type = string
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU."
  type = string
  default = "AL2_x86_64"
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes. Defaults to 20."
  type = number
  default = 20
}

variable "instance_types" {
  type = list(string)
  default = ["t3.micro"]
  description = "Set of instance types associated with the EKS Node Group."
}

variable "pvt_desired_size" {
  description = "Desired number of worker nodes in private subnet"
  default = 2
  type = number
}

variable "pvt_max_size" {
  description = "Maximum number of worker nodes in private subnet."
  default = 2
  type = number
}

variable "pvt_min_size" {
  description = "Minimum number of worker nodes in private subnet."
  default = 1
  type = number
}

variable "pblc_desired_size" {
  description = "Desired number of worker nodes in public subnet"
  default = 2
  type = number
}

variable "pblc_max_size" {
  description = "Maximum number of worker nodes in public subnet."
  default = 3
  type = number
}

variable "pblc_min_size" {
  description = "Minimum number of worker nodes in public subnet."
  default = 1
  type = number
}