# Module 01 - Networking Concepts

## VPC
- What it is:
- CIDR block:
- Why enable_dns_hostnames:
- Why enable_dns_support:

## Subnets
- Public vs Private difference:
- Why 2 AZs:
- map_public_ip_on_launch:

## Internet Gateway
- What it does:
- How many per VPC:

## NAT Gateway
- What it does:
- Why it lives in public subnet:
- Why 2 NAT Gateways (not 1):
- Cost consideration:

## Route Tables
- What they do:
- Public RT rule:
- Private RT rule:
- What makes a subnet public:

## Security Groups
- Stateful meaning:
- Rules type (allow/deny):
- protocol = "-1":
- 0.0.0.0/0 vs 10.0.0.0/16:

## NACLs
- Stateless meaning:
- Why ephemeral ports 1024-65535:
- Rule numbering convention:
- When to use NACLs vs SGs:

## Bastion Host vs SSM
- What a bastion host is:
- Why SSM Session Manager is preferred: