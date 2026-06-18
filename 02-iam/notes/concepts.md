# Module 02 - IAM Concepts

## IAM Users vs Roles
Users    => permanent identity, long-lived credentials (access key + secret) used by humans and CI/CD pipelines
Roles    => temporary identity, short-lived tokens (15min - 12hr) used by AWS services, EC2 instances, pods safer than users for services - credentials expire automatically

## Policy Types
AWS Managed   => pre-written by AWS, maintained by AWS, cannot edit e.g. AmazonEKSClusterPolicy, AmazonEC2ContainerRegistryReadOnly
Custom        => you write it, you own it, full control always prefer over managed when you need least privilege

## Policy Document Structure
{
  "Version": "2012-10-17",     ← always this date, it's a format version
  "Statement": [{
    "Sid":      "FriendlyName" ← optional label for the statement
    "Effect":   "Allow|Deny"  ← only two options
    "Action":   "service:Action" ← what API calls are permitted
    "Resource": "arn:..."     ← which specific resources
    "Condition": {}           ← optional, adds restrictions
  }]
}

## Evaluation Logic
Explicit Deny > Explicit Allow > Implicit Deny (default)
If no Allow found => access denied automatically

## Trust Policy vs Permission Policy
Trust Policy      => WHO can assume this role (the Principal) always contains sts:AssumeRole
Permission Policy => WHAT the role can do once assumed

## Principals in Trust Policies
ec2.amazonaws.com   => EC2 instances can assume this role
eks.amazonaws.com   => EKS control plane can assume this role
lambda.amazonaws.com => Lambda functions can assume this role

## Three Roles We Built
EKS Cluster Role  => assumed by EKS control plane (eks.amazonaws.com) manages EC2, ELB, networking on your behalf
EKS Node Role     => assumed by worker nodes (ec2.amazonaws.com) pulls ECR images, registers with cluster, sends logs
IRSA Role         => assumed by specific pods (federated OIDC principal) scoped to one Kubernetes service account

## Instance Profile
EC2 cannot attach an IAM role directly.
Instance Profile is the wrapper that holds the role.
EKS node groups reference the instance profile, not the role.
aws_iam_instance_profile => aws_iam_role (one role per profile)

## IRSA - IAM Roles for Service Accounts
Problem: node role permissions apply to ALL pods on that node
Solution: IRSA gives each pod its own IAM role via OIDC

Flow:
1. EKS OIDC provider acts as identity bridge
2. Pod has a Kubernetes Service Account annotated with role ARN
3. EKS injects signed OIDC token into pod
4. Pod calls sts:AssumeRoleWithWebIdentity
5. AWS validates token, returns temporary credentials
6. Only that pod gets those credentials

## Three Policy Node Attachments (Worker Nodes)
AmazonEKSWorkerNodePolicy          => register with control plane
AmazonEKS_CNI_Policy               => manage ENIs and pod IPs
AmazonEC2ContainerRegistryReadOnly => pull images (READ ONLY, never push)

## How to Write Any IAM Policy from Scratch
1. What does this thing need to DO? (plain English)
2. Which AWS service/action handles that?
3. On which specific resources? (scope the ARN tightly)

## Key Questions
Q: Why not use AdministratorAccess on worker nodes?
A: Violates least privilege. Compromised node = compromised account.
   Nodes need ECR pull, CloudWatch write, EKS registration only.

Q: Why can't you attach an IAM role directly to EC2?
A: AWS requires an Instance Profile wrapper. Common mistake.

Q: What is IRSA and why does it exist?
A: Node roles give permissions to ALL pods on a node.
   IRSA scopes permissions to a specific pod via OIDC tokens.
   Each workload gets exactly what it needs, nothing more.

Q: Difference between AWS managed and custom policies?
A: Managed = AWS writes and maintains, convenient but broad.
   Custom = you write it, full control, always prefer for least privilege.

## IAM Actions Reference
https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html