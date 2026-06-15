# Module 01 - Networking Concepts

## VPC

- What it is:
  A logically isolated network inside AWS. You own the IP space,
  routing rules, and firewall controls. Nobody else's traffic
  enters unless explicitly allowed.
- CIDR block:
  CIDR /16 = 65,536 addresses. Subnets carve slices out of this range.

- Why enable_dns_hostnames:
  enable_dns_hostnames = true (required for EKS)

- Why enable_dns_support:
  enable_dns_support = true (enables AWS internal DNS)

## Subnets

- Public vs Private difference:
  Slices of the VPC CIDR assigned to a specific Availability Zone.
  /24 = 256 addresses per subnet.

- Why 2 AZs:
  2 AZs so when one is down (e.g., catches fire) the other is still up and running.

- map_public_ip_on_launch:
  Public subnet => map_public_ip_on_launch = true + route to IGW
  Private subnet => map_public_ip_on_launch = false + route to NAT GW

## Internet Gateway

The door between the VPC and the public internet.

- What it does:
  Without it, nothing inside the VPC can reach the internet.

- How many per VPC:
  One IGW per VPC. Stateless - just a target for route tables.

## NAT Gateway

Has an Elastic IP (fixed public IP).

- What it does:
  Allows private subnet resources to initiate outbound internet
  connections. Blocks all inbound connections from the internet.

- Why it lives in public subnet:
  Lives in the PUBLIC subnet because it needs a route to the IGW.

- Why 2 NAT Gateways (not 1):
  One per AZ for high availability. One for both AZs saves cost
  but creates single point of failure. Use two in production.

- Cost consideration:

## Route Tables

- What they do:
  A rulebook that answers: "where does this packet go?"
  Every subnet must be associated with a route table.

- Public RT rule:
  Public RT: 0.0.0.0/0 => IGW (direct internet access)

- Private RT rule:
  Private RT: 0.0.0.0/0 → NAT GW (outbound only, no inbound)

- What makes a subnet public:
  Local route (10.0.0.0/16 → local) is always present, added by AWS.

## Security Groups (Stateful)
- Attached to individual resources (EC2, RDS, ALB, EKS nodes)

- Stateful meaning:
  Stateful: return traffic is automatically allowed
- Rules type (allow/deny):
 Allow rules only - cannot deny
 All rules evaluated, most permissive wins

- protocol = "-1":
  protocol = "-1" means all protocols - TCP, UDP, ICMP, everything. AWS uses -1 as the wildcard.

- 0.0.0.0/0 vs 10.0.0.0/16:
  0.0.0.0/0 in a SG rule = the public internet
  10.0.0.0/16 in a SG rule = internal VPC traffic only

| NB: Allow any resource inside the VPC (10.0.0.0/16) to talk to any other resource inside the VPC, regardless of which subnet they're in.

## NACLs (Stateless)
 Attached to subnets - applies to everything inside

- Stateless meaning:
Stateless: must explicitly allow BOTH inbound AND outbound
Supports allow AND deny rules

- Implicit DENY ALL at the end (rule *)

- Why ephemeral ports 1024-65535:
Ephemeral Ports (1024-65535)
Return traffic uses random high ports chosen by the OS.
Security Groups handle this automatically (stateful).
NACLs require an explicit rule allowing 1024-65535 (stateless).
Forgetting this is one of the most common AWS networking bugs.

- Rule numbering convention:
 Rules evaluated in number order - first match wins
 Always leave gaps in rule numbers (100, 110, 120)

- When to use NACLs vs SGs:
| Use Security Groups for:
- Everything, by default
- Resource-level rules (this EC2, this RDS, this ALB)
- Allow rules between specific resources e.g. "allow EKS nodes to talk to RDS on port 5432"
- Referencing other security groups as source
  e.g. "allow traffic FROM the ALB security group" (not an IP range)

| Use NACLs for:
- Blocking specific IP ranges at subnet level
  e.g. "block this known malicious IP from entering the subnet"
- Compliance requirements (PCI-DSS, HIPAA)
  demand subnet-level controls in addition to resource-level
- Explicit deny rules (SGs cannot deny, only allow)
- Second line of defence when SGs are misconfigured\

### The golden rule:
Security Groups handle 95% of cases.
NACLs are your safety net and compliance layer.
Never rely on NACLs alone -- always have SGs too.
Always have both in production for defence in depth.

## Bastion Host vs SSM

- What a bastion host is:
Bastion Host - EC2 in public subnet, SSH in then hop to private

- Why SSM Session Manager is preferred:
SSM Session Manager - no port 22 needed, access via AWS API
   Production preference: SSM (zero network exposure)


## Key Questions
Q: What makes a subnet public?
A: A route table entry: 0.0.0.0/0 → IGW, plus map_public_ip_on_launch = true

Q: What is the difference between a Security Group and a NACL?
A: SGs are stateful, resource-level, allow-only.
   NACLs are stateless, subnet-level, allow and deny.

Q: Why does NAT Gateway live in the public subnet?
A: It needs a route to the IGW to forward outbound traffic.
   In a private subnet it would have no path to the internet.

Q: Why two NAT Gateways?
A: High availability. One per AZ. If AZ1 goes down, AZ2 is
   self-sufficient with its own NAT GW and private route table.