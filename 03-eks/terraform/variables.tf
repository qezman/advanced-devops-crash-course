variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "devops-course"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID from networking module"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDS from networking module"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDS from networking module"
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "EKS cluster IAM role ARN from IAM module"
  type        = string
}

variable "eks_node_role_arn" {
  description = "EKS node IAM role ARN from IAM module"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}
