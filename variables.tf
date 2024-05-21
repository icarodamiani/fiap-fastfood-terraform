# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions

variable "aws_region" {
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

