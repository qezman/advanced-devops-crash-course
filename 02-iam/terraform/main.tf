# EKS CLUSTER ROLE
resource "aws_iam_role" "eks_cluster" {
  name        = "${var.project_name}-eks-cluster-role"
  description = "IAM role for EKS control plane"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-eks-cluster-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# EKS Node Role
resource "aws_iam_role" "eks_node" {
  name        = "${var.project_name}-eks-node-role"
  description = "IAM role for EKS worker nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-eks-node-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Attach managed policies to node role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Custom policy
resource "aws_iam_policy" "eks_node_cloudwatch" {
  name        = "${var.project_name}-eks-node-eks_node_cloudwatch"
  description = "Allow EKS nodes to send logs to cloudwatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/eks/*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-eks-node-cloudwatch"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_cloudwatch" {
  role       = aws_iam_role.eks_node.name
  policy_arn = aws_iam_policy.eks_node_cloudwatch.arn
}

# Attach aws managed policy to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Instance profile
resource "aws_iam_instance_profile" "eks_node" {
  name = "${var.project_name}-eks-node-profile"
  role = aws_iam_role.eks_node.name

  tags = {
    Name        = "${var.project_name}-eks-node-profile"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# OIDC provider data source
# data "aws_eks_cluster" "main" {
#   name = "${var.project_name}-cluster"
# }

# data "aws_iam_openid_connect_provider" "eks" {
#   url = data.aws_eks_cluster.main.identity[0].oidc.issuer
# }

# IRSA roles
# resource "aws_iam_role" "irsa_s3_reader" {
#   name        = "${var.project_name}-irsa-s3-reader"
#   description = "IRSA for pods that need s3 access"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = data.aws_iam_openid_connect_provider.eks.arn
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "${data.aws_iam_openid_connect_provider.eks.url}:sub" = "system:serviceaccount:default:s3-reader-sa"
#             "${data.aws_iam_openid_connect_provider.eks.url}:aud" = "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
#   tags = {
#     Name        = "${var.project_name}-irsa-s3-reader"
#     Environment = var.environment
#     ManagedBy   = "terraform"
#   }
# }

# IRSA policy
# resource "aws_iam_policy" "s3_reader" {
#   name        = "${var.project_name}-s3-reader-policy"
#   description = "Allow specific S3 bucket read access"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "S3ReadAccess"
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           "arn:aws:s3:::${var.project_name}-data",
#           "arn:aws:s3:::${var.project_name}-data/*"
#         ]
#       }
#     ]
#   })
#   tags = {
#     Name        = "${var.project_name}-s3-reader-policy"
#     Environment = var.environment
#     ManagedBy   = "terraform"
#   }
# }

# resource "aws_iam_role_policy_attachment" "irsa_s3_reader" {
#   role       = aws_iam_role.irsa_s3_reader.name
#   policy_arn = aws_iam_policy.s3_reader.arn
# }
