# Shopping Cart E-Commerce Application - Complete Documentation

**Version**: 1.0  
**Created**: June 2026  
**Last Updated**: June 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Infrastructure Components](#infrastructure-components)
4. [Terraform Configuration](#terraform-configuration)
5. [Terraform Variables Guide](#terraform-variables-guide)
6. [Docker & Container Setup](#docker--container-setup)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Deployment Process](#deployment-process)
9. [Environment Variables](#environment-variables)
10. [Pre-Deployment Checklist](#pre-deployment-checklist)
11. [Infrastructure Deployment Checklist](#infrastructure-deployment-checklist)
12. [CircleCI Configuration Checklist](#circleci-configuration-checklist)
13. [First Deployment Checklist](#first-deployment-checklist)
14. [Post-Deployment Checklist](#post-deployment-checklist)
15. [Troubleshooting](#troubleshooting)
16. [Monitoring & Maintenance](#monitoring--maintenance)

---

# PART 1: OVERVIEW & ARCHITECTURE

## Overview

This document describes the complete infrastructure setup for the Shopping Cart E-commerce application. The infrastructure is fully automated using Terraform and deployed via CircleCI to AWS.

**Stack:**
- **IaaC**: Terraform
- **Cloud Provider**: AWS
- **Container Registry**: Amazon ECR (Elastic Container Registry)
- **Compute**: EC2 (with Elastic IP)
- **Load Balancing**: Application Load Balancer (ALB)
- **Networking**: VPC with public/private subnets
- **CI/CD**: CircleCI
<!-- Professional, executive-ready single-file documentation -->
# Shopping Cart E‑Commerce — Infrastructure & Deployment Overview

Version: 1.1
Date: June 23, 2026

Prepared for: VP Engineering
Prepared by: Platform/DevOps Team

Executive summary
-----------------
- Purpose: Provide a concise, business-focused summary of the proposed
  production deployment architecture, infrastructure components, CI/CD
  pipeline, and operational procedures required to run the Shopping Cart
  E‑Commerce application on AWS.
- Outcome: Infrastructure codified in Terraform, container images stored in
  ECR, application deployed to a single EC2 instance (Docker Compose) with
  an Application Load Balancer (ALB) and an Elastic IP for stable access.
- Key benefits: repeatable infrastructure, automated build-and-deploy,
  ECR image scanning, and basic operational runbook for monitoring and
  recovery.

Notable deliverables
--------------------
- Terraform modules: `network`, `ec2`, `ecr` (VPC, subnets, ALB, EC2,
  Elastic IP, ECR repository).
- CircleCI pipeline: `build-and-push` (build image, push to ECR) and
  `deploy` (SSH to EC2, pull image, Docker Compose up).
- Documentation: single-file executive report (this document), technical
  guides, and deployment checklists.

High-level architecture
-----------------------
Components and responsibilities:
- VPC: isolates networking, two public subnets (AZ redundancy), IGW and
  route tables.
- Application Load Balancer (ALB): receives traffic on port 80 and
  forwards to target group on EC2 port 5000. Provides health checks.
- EC2: Ubuntu instance running Docker Engine and Docker Compose. IAM role
  grants read access to ECR. Elastic IP attached for stable SSH/URL.
- ECR: stores Docker artifacts; images are scanned on push and lifecycle
  policies remove old images.
- CircleCI: orchestrates CI/CD — builds and pushes images, then deploys
  them to the EC2 host.

Architecture (text diagram)
---------------------------
VPC (public subnets) → ALB (port 80) → EC2 (Docker container on port 5000)

Implementation summary
----------------------
- Infrastructure-as-Code: Terraform modules with outputs for ALB DNS,
  instance IDs, and Elastic IP address.
- Image lifecycle: CircleCI builds application image, tags `latest`, and
  pushes to ECR. ECR scan-on-push enabled.
- Deployment model: EC2 runs Docker Compose to start containers from ECR
  images. The CircleCI `deploy` job SSHs to the instance, pulls images and
  restarts services.

Security & compliance highlights
-------------------------------
- Least-privilege IAM: EC2 has instance profile limited to ECR read-only permissions.
- Secrets: CircleCI stores AWS credentials and SSH private keys as encrypted
  environment variables — do not store secrets in Git.
- Networking: Security groups lock down SSH and HTTP access to intended
  sources; ALB sits in a public subnet with health checks.

Operational plan (runbook highlights)
-----------------------------------
- Monitoring: Use CloudWatch for EC2 and ALB metrics; set alarms for
  unhealthy targets, CPU, and disk usage.
- Logs: Docker container logs available on the host (accessible via SSH).
- Backups: EBS snapshots planned for recovery; Terraform state stored in
  S3 (recommended) with versioning.

Deployment & rollback
---------------------
Standard deployment flow (executed by CircleCI):
1. `build-and-push` job builds Docker image and pushes to ECR.
2. `deploy` job SSHs to EC2, pulls the new image, and performs `docker
   compose up -d --no-build`.

Quick rollback options:
- Roll back to previous image tag and restart Compose.
- Revert last commit and allow CircleCI to redeploy the previous image.

Cost & capacity note
--------------------
- Current design targets a single EC2 instance (t3.medium by default)
  with an ALB and ECR storage. Review instance sizing after traffic testing.

Risk assessment & mitigations
----------------------------
- Single-instance risk: EC2 is a single compute node — if it fails, ALB
  health checks will fail. Mitigation: introduce Auto Scaling Group (ASG)
  and multiple instances across AZs for production.
- Security exposure: SSH access must be tightly controlled. Mitigation:
  restrict source IPs or use a bastion host; rotate keys regularly.
- State management: Terraform state must be stored securely (S3 +
  locking). Mitigation: enable S3 backend with DynamoDB lock table.

Appendix: concise technical references
-------------------------------------
- Terraform modules: `terraform/modules/network`, `terraform/modules/ec2`,
  `terraform/modules/ecr`.
- Key files:
  - `terraform/main.tf` — root infra orchestration and module wiring
  - `.circleci/config.yml` — CI/CD pipeline
  - `docker-compose.yml` — runtime composition (used on EC2)
  - `Dockerfile` — application image build

Actionable next steps (recommended for VP approval)
-------------------------------------------------
1. Approve production changes: move from single EC2 to an ASG-backed
   deployment for high availability.
2. Approve budget for monitoring and backups (CloudWatch/CloudTrail,
   EBS snapshot schedule).
3. Approve security hardening plan: lock SSH, implement key rotation,
   and enable VPC Flow Logs.

Deliverables submitted
----------------------
- This executive report (PDF/Markdown).
- Terraform code (in repository `terraform/`).
- CircleCI pipeline (in `.circleci/config.yml`).
- Deployment checklists and variables guide.

Contact & ownership
-------------------
- Platform Owner: [Platform Team Lead]
- Dev Owner: [Backend Team Lead]
- For urgent issues: PagerDuty / On-call rotation (configure as needed)

Document history
----------------
- Version 1.0 — Initial technical draft (June 2026)
- Version 1.1 — Polished executive report and action list (June 23, 2026)

-- End of report --

## EC2 Module (`modules/ec2/`)
Creates EC2 instance, IAM role, key pair, and Elastic IP.

**Key Outputs:**
- `instance_id`: EC2 instance ID
- `instance_public_ip`: Public IP address
- `instance_elastic_ip`: Elastic IP address
- `instance_eip_allocation_id`: Allocation ID of Elastic IP

## ECR Module (`modules/ecr/`)
Creates ECR repository with lifecycle policies and security scanning.

**Key Outputs:**
- `repository_url`: Full ECR repository URL
- `repository_arn`: Repository ARN
- `registry_id`: AWS Account ID

---

# PART 4: TERRAFORM VARIABLES GUIDE

## Overview

Variables are defined in `variables.tf` files at two levels:

1. **Root Level** (`terraform/variables.tf`) - Main infrastructure inputs
2. **Module Level** (`terraform/modules/*/variables.tf`) - Module-specific inputs

---

## AWS Region

**Variable**: `region`  
**Type**: string  
**Required**: Yes  
**Description**: AWS region where resources will be deployed

**Example Values**:
```hcl
region = "us-east-1"       # US East (N. Virginia)
region = "us-west-2"       # US West (Oregon)
region = "eu-west-1"       # Europe (Ireland)
region = "ap-southeast-1"  # Asia Pacific (Singapore)
```

---

## VPC and Networking Variables

### VPC CIDR Block
**Variable**: `vpc_cidr`  
**Type**: string  
**Required**: Yes  
**Description**: CIDR block for the VPC

**Recommended Values**:
```hcl
vpc_cidr = "10.0.0.0/16"    # 65,536 IP addresses
vpc_cidr = "172.16.0.0/16"  # Alternative
vpc_cidr = "192.168.0.0/16" # Alternative
```

**Notes**:
- Avoid overlapping with existing networks
- `/16` provides ~65k addresses
- Use `/24` (256 addresses) for test environments

### Public Subnet A CIDR
**Variable**: `subnet_cidr`  
**Type**: string  
**Required**: Yes  
**Description**: CIDR block for the first public subnet

**Example**:
```hcl
vpc_cidr = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"    # First subnet
subnet_cidr_b = "10.0.2.0/24"  # Second subnet
```

### Public Subnet B CIDR
**Variable**: `subnet_cidr_b`  
**Type**: string  
**Required**: Yes  
**Description**: CIDR block for the second public subnet

### VPC Name
**Variable**: `vpc_name`  
**Type**: string  
**Required**: Yes  
**Description**: Name tag for the VPC

**Example Values**:
```hcl
vpc_name = "shopping-cart-vpc"
vpc_name = "ecom-app-vpc"
vpc_name = "shopping-cart-prod"
```

### Subnet Names
**Variable**: `subnet_name`  
**Type**: string  
**Required**: Yes  
**Description**: Name tag for subnets

**Example**:
```hcl
subnet_name = "shopping-cart-subnet"
```

### Internet Gateway Name
**Variable**: `igw_name`  
**Type**: string  
**Required**: Yes  
**Description**: Name tag for the Internet Gateway

**Example**:
```hcl
igw_name = "shopping-cart-igw"
```

### Route Table Name
**Variable**: `route_table_name`  
**Type**: string  
**Required**: Yes  
**Description**: Name tag for the route table

**Example**:
```hcl
route_table_name = "shopping-cart-rt"
```

---

## EC2 Instance Variables

### AMI (Amazon Machine Image)
**Variable**: `ami`  
**Type**: string  
**Required**: Yes  
**Description**: AMI ID for the EC2 instance operating system

**Ubuntu 20.04 LTS by Region**:
```hcl
# us-east-1
ami = "ami-0c55b159cbfafe1f0"

# us-west-2
ami = "ami-0c2d06d50ce30b70c"

# eu-west-1
ami = "ami-0d71ea30463e0ff8d"

# ap-southeast-1
ami = "ami-0cd31be676780afa7"
```

**How to Find AMI ID via AWS CLI**:
```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].[ImageId,Name]' \
  --region us-east-1
```

### Instance Type
**Variable**: `instance_type`  
**Type**: string  
**Required**: Yes  
**Description**: EC2 instance type (compute, memory, storage specifications)

**Recommended Options**:
```hcl
# Development/Testing
instance_type = "t3.small"      # 2 vCPU, 2 GB RAM, low cost
instance_type = "t3.medium"     # 2 vCPU, 4 GB RAM, burst capable

# Production (light traffic)
instance_type = "t3.large"      # 2 vCPU, 8 GB RAM
instance_type = "t3.xlarge"     # 4 vCPU, 16 GB RAM

# Production (heavy traffic)
instance_type = "m5.large"      # 2 vCPU, 8 GB RAM, general purpose
instance_type = "m5.xlarge"     # 4 vCPU, 16 GB RAM
instance_type = "m5.2xlarge"    # 8 vCPU, 32 GB RAM

# High CPU demand
instance_type = "c5.large"      # 2 vCPU, 4 GB RAM, compute optimized
instance_type = "c5.xlarge"     # 4 vCPU, 8 GB RAM
```

**Selection Guide**:
- **t3** instances: Cost-effective with burstable performance
- **m5** instances: Balanced compute/memory
- **c5** instances: High CPU, lower memory

**Default Recommendation**: `t3.medium`

### SSH Key Pair Name
**Variable**: `key_name`  
**Type**: string  
**Required**: Yes  
**Description**: Name of the EC2 key pair for SSH access

**Example**:
```hcl
key_name = "shopping-cart-key"
```

### EC2 SSH Public Key
**Variable**: `ec2_ssh_public_key`  
**Type**: string  
**Required**: Yes  
**Description**: Public key content for SSH access

**Example**:
```hcl
ec2_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx... user@machine"
```

**How to Get Public Key from Private Key**:
```bash
ssh-keygen -y -f shopping-cart-key.pem
```

### GitHub Repository URL
**Variable**: `github_repo_url`  
**Type**: string  
**Required**: Yes  
**Description**: Git repository URL for cloning on EC2

**Example**:
```hcl
github_repo_url = "https://github.com/user/shopping-cart-ecom.git"
```

---

## ECR Variables

### ECR Repository Name
**Variable**: `ecr_repository_name`  
**Type**: string  
**Required**: Yes  
**Description**: Name of the Amazon ECR repository

**Example**:
```hcl
ecr_repository_name = "shopping-cart-ecom"
```

**Rules**:
- Must be lowercase
- Can contain hyphens, underscores
- Must be unique within AWS account + region
- 1-256 characters

---

## Complete terraform.tfvars Example

```hcl
# AWS Region
region = "us-east-1"

# VPC Configuration
vpc_cidr         = "10.0.0.0/16"
vpc_name         = "shopping-cart-vpc"

# Subnets
subnet_cidr      = "10.0.1.0/24"
subnet_cidr_b    = "10.0.2.0/24"
subnet_name      = "shopping-cart-subnet"

# Internet Gateway & Route Table
igw_name         = "shopping-cart-igw"
route_table_name = "shopping-cart-rt"

# EC2 Instance
ami                = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS (us-east-1)
instance_type      = "t3.medium"
key_name           = "shopping-cart-key"
ec2_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAA... your-name@your-machine"

# GitHub Repository
github_repo_url    = "https://github.com/user/shopping-cart-ecom.git"

# ECR Repository
ecr_repository_name = "shopping-cart-ecom"
```

---

# PART 5: DOCKER & CONTAINER SETUP

## Dockerfile
- **Base Image**: Multi-stage build
- **Stage 1 - Build**:
  - Uses .NET build image
  - Restores NuGet packages
  - Publishes .NET application
- **Stage 2 - Runtime**:
  - Uses .NET runtime image
  - Copies published app
  - Exposes port 5000
  - Sets ASPNETCORE_URLS to `http://+:5000`

## docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/shopping-cart-ecom:latest
    container_name: shopping-cart-app
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
    restart: unless-stopped
```

**Note**: The image is pulled from ECR, not built locally during deployment.

---

# PART 6: CI/CD PIPELINE

## CircleCI Configuration (`.circleci/config.yml`)

### Job 1: `build-and-push`
**Purpose**: Build Docker image and push to ECR

**Steps:**
1. Checkout repository code
2. Install AWS CLI and Python
3. Validate AWS configuration
4. Authenticate to ECR using AWS credentials
5. Build Docker image with ECR registry tag
6. Push image to ECR

**Required Environment Variables:**
- `AWS_ACCOUNT_ID`: Your AWS account ID
- `AWS_DEFAULT_REGION`: AWS region (e.g., us-east-1)
- `ECR_REPOSITORY`: Repository name
- `AWS_ACCESS_KEY_ID`: AWS IAM access key
- `AWS_SECRET_ACCESS_KEY`: AWS IAM secret key

### Job 2: `deploy`
**Purpose**: Deploy application to EC2 via Docker Compose

**Steps:**
1. Checkout repository code
2. Install AWS CLI
3. Setup SSH key for EC2 access
4. Validate deployment configuration
5. Verify EC2 connectivity (retry up to 30 times)
6. Install Docker, Git, and Docker Compose on EC2
7. Clone or update Git repository on EC2
8. Copy environment file to EC2
9. Pull latest image from ECR
10. Stop and remove old containers
11. Start new containers with Docker Compose

**Required Environment Variables:**
- `EC2_HOST`: EC2 instance IP or hostname
- `DEPLOYMENT_USER`: SSH user (typically `ubuntu`)
- `DEPLOYMENT_PATH`: Path on EC2 to deploy (e.g., `/opt/app`)
- `EC2_SSH_PRIVATE_KEY`: Private SSH key for EC2 access
- Plus all from `build-and-push` job

### Workflow: `build-deploy`
```
build-and-push → deploy
```

The `deploy` job depends on `build-and-push` completing successfully.

---

# PART 7: DEPLOYMENT PROCESS

## Prerequisites
1. AWS Account with appropriate permissions
2. CircleCI connected to GitHub repository
3. EC2 key pair created in AWS
4. IAM user with ECR and EC2 permissions

## Step-by-Step Deployment

### Step 1: Initial Infrastructure Setup
```bash
cd terraform

# Initialize Terraform
terraform init -backend-config="bucket=YOUR_BUCKET" \
               -backend-config="key=shopping-cart/terraform.tfstate" \
               -backend-config="region=us-east-1"

# Plan changes
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

### Step 2: CircleCI Configuration
1. Go to CircleCI dashboard
2. Add environment variables:
   - `AWS_ACCOUNT_ID`
   - `AWS_DEFAULT_REGION`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `ECR_REPOSITORY`
   - `EC2_HOST` (Elastic IP)
   - `DEPLOYMENT_USER`
   - `DEPLOYMENT_PATH`
   - `EC2_SSH_PRIVATE_KEY`
   - `GIT_REPOSITORY_URL`

### Step 3: Push Code & Deploy
```bash
git push origin main
```

CircleCI automatically:
1. Builds Docker image
2. Pushes to ECR
3. SSHs into EC2
4. Pulls latest image
5. Runs Docker Compose

### Step 4: Access Application
Once deployed, access via:
- **Direct**: `http://<ELASTIC_IP>:5000`
- **ALB DNS**: `http://<ALB_DNS_NAME>`

---

# PART 8: ENVIRONMENT VARIABLES

## `.circleci/.env.example`

```bash
# AWS Configuration
AWS_ACCOUNT_ID=123456789012
AWS_DEFAULT_REGION=us-east-1
ECR_REPOSITORY=shopping-cart-ecom

# EC2 Configuration
EC2_HOST=your-elastic-ip.compute.amazonaws.com
DEPLOYMENT_USER=ubuntu
DEPLOYMENT_PATH=/opt/shopping-cart-app

# Application Configuration
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:5000
```

## CircleCI Environment Variables

Set these in CircleCI project settings (not in git):
- `AWS_ACCOUNT_ID`
- `AWS_DEFAULT_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ECR_REPOSITORY`
- `EC2_HOST`
- `DEPLOYMENT_USER`
- `DEPLOYMENT_PATH`
- `EC2_SSH_PRIVATE_KEY`
- `GIT_REPOSITORY_URL`

---

# PART 9: PRE-DEPLOYMENT CHECKLIST

## AWS Account Setup
- [ ] AWS Account created and active
- [ ] IAM user created with appropriate permissions:
  - [ ] EC2 full access
  - [ ] ECR full access
  - [ ] VPC full access
  - [ ] IAM role creation permissions
- [ ] AWS CLI installed locally
- [ ] AWS credentials configured locally (`aws configure`)
- [ ] Default region set correctly

## Repository Setup
- [ ] GitHub repository cloned locally
- [ ] Repository has CircleCI integration
- [ ] `.circleci/config.yml` exists and is valid YAML
- [ ] `Dockerfile` exists and builds successfully locally

## Terraform Setup
- [ ] Terraform installed (v1.0+)
- [ ] S3 bucket created for Terraform state (optional but recommended)
- [ ] `terraform.tfvars` file created with correct values:
  - [ ] AMI ID for Ubuntu 20.04 LTS in your region
  - [ ] EC2 instance type specified
  - [ ] SSH public key content added
  - [ ] GitHub repository URL added
  - [ ] Region matches your AWS default region

## SSH Key Setup
- [ ] EC2 key pair created in AWS Console (or via Terraform)
- [ ] Private key downloaded and stored securely locally
- [ ] Key file permissions set: `chmod 600 key.pem`
- [ ] Public key content extracted for `terraform.tfvars`

---

# PART 10: INFRASTRUCTURE DEPLOYMENT CHECKLIST

## Step 1: Initialize Terraform
- [ ] Navigate to `terraform/` directory
- [ ] Run: `terraform init`
- [ ] Backend configuration specified (if using S3)
- [ ] Terraform initialized successfully

## Step 2: Plan Infrastructure
- [ ] Run: `terraform plan -out=tfplan`
- [ ] Review planned resources:
  - [ ] VPC
  - [ ] Subnets (2)
  - [ ] Internet Gateway
  - [ ] Route Tables
  - [ ] Security Groups (2)
  - [ ] EC2 Instance
  - [ ] Elastic IP
  - [ ] ALB
  - [ ] ECR Repository
- [ ] No errors or warnings
- [ ] Resource count matches expectations

## Step 3: Apply Infrastructure
- [ ] Run: `terraform apply tfplan`
- [ ] Wait for completion (5-10 minutes)
- [ ] Note the outputs:
  - [ ] `instance_public_ip` - Save for later
  - [ ] `instance_elastic_ip` - This is your Elastic IP
  - [ ] `alb_dns_name` - ALB endpoint
  - [ ] `ecr_repository_url` - ECR repository URL
- [ ] EC2 instance is running
- [ ] Elastic IP is associated with EC2
- [ ] ALB is created and in "active" state

## Step 4: Verify Infrastructure
```bash
# Verify EC2 instance
aws ec2 describe-instances --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]'

# Verify Elastic IP
aws ec2 describe-addresses --query 'Addresses[0].[PublicIp,InstanceId]'

# Verify ECR repository
aws ecr describe-repositories --repository-names shopping-cart-ecom

# Verify ALB
aws elbv2 describe-load-balancers --names shopping-cart-alb
```

- [ ] EC2 instance state is "running"
- [ ] Elastic IP is allocated and associated
- [ ] ECR repository exists
- [ ] ALB is "active"

---

# PART 11: CIRCLECI CONFIGURATION CHECKLIST

## Step 1: Set Environment Variables
Go to CircleCI Project Settings → Environment Variables

- [ ] `AWS_ACCOUNT_ID` - Your 12-digit AWS account ID
- [ ] `AWS_DEFAULT_REGION` - e.g., `us-east-1`
- [ ] `AWS_ACCESS_KEY_ID` - IAM user access key
- [ ] `AWS_SECRET_ACCESS_KEY` - IAM user secret key
- [ ] `ECR_REPOSITORY` - e.g., `shopping-cart-ecom`
- [ ] `EC2_HOST` - Elastic IP address or hostname
- [ ] `DEPLOYMENT_USER` - e.g., `ubuntu`
- [ ] `DEPLOYMENT_PATH` - e.g., `/opt/shopping-cart-app`
- [ ] `EC2_SSH_PRIVATE_KEY` - Full private key content
- [ ] `GIT_REPOSITORY_URL` - e.g., `https://github.com/user/repo.git`

## Step 2: Verify Environment Variables
- [ ] All required variables are set
- [ ] Variables contain actual values (not placeholders)
- [ ] `EC2_SSH_PRIVATE_KEY` includes full key with header
- [ ] No accidental spaces or trailing newlines

## Step 3: Test CircleCI Configuration
- [ ] `.circleci/config.yml` is valid YAML
- [ ] Run: `circleci config validate`
- [ ] No syntax errors reported

---

# PART 12: FIRST DEPLOYMENT CHECKLIST

## Step 1: Push Code to GitHub
```bash
git add .
git commit -m "Initial infrastructure and deployment setup"
git push origin main
```

- [ ] Code pushed to `main` branch
- [ ] No merge conflicts

## Step 2: Monitor CircleCI Build
In CircleCI Dashboard:

- [ ] Workflow started automatically
- [ ] `build-and-push` job runs:
  - [ ] Code checked out
  - [ ] AWS CLI installed
  - [ ] Docker image built successfully
  - [ ] Image pushed to ECR successfully
  - [ ] Job completed with status "success"

## Step 3: Verify ECR Image
```bash
aws ecr describe-images --repository-name shopping-cart-ecom --query 'imageDetails[0].[imageTags,imageSizeInBytes]'
```

- [ ] Image appears in ECR
- [ ] Image has tag `latest`
- [ ] Image size is reasonable (> 100MB)

## Step 4: Monitor Deployment Job
In CircleCI Dashboard:

- [ ] `deploy` job starts after `build-and-push` completes
- [ ] SSH connection to EC2 established
- [ ] Docker and dependencies installed on EC2
- [ ] Repository cloned/updated on EC2
- [ ] Docker image pulled from ECR
- [ ] Containers started with Docker Compose
- [ ] Deployment completed with status "success"

## Step 5: Verify Application Running
```bash
# SSH into EC2
ssh -i key.pem ubuntu@ELASTIC_IP

# Check running containers
docker ps

# Check application logs
docker logs shopping-cart-app
```

- [ ] Container `shopping-cart-app` is running
- [ ] No error logs
- [ ] Application listening on port 5000

## Step 6: Test Application Access
```bash
# Via Elastic IP
curl -i http://ELASTIC_IP:5000/

# Via ALB (wait 30 seconds for health checks)
curl -i http://ALB_DNS_NAME/
```

- [ ] HTTP 200 or appropriate response
- [ ] Application returns expected content
- [ ] Both endpoints work

---

# PART 13: POST-DEPLOYMENT CHECKLIST

## Monitoring
- [ ] Set up CloudWatch alarms for:
  - [ ] EC2 CPU usage
  - [ ] EC2 disk usage
  - [ ] ALB target health
  - [ ] ECR repository size
- [ ] Enable VPC Flow Logs
- [ ] Configure CloudTrail for audit logging

## Security Hardening
- [ ] Review and tighten security group rules
- [ ] Disable root password login on EC2
- [ ] Configure SSH key-based auth only
- [ ] Enable encryption on EBS volumes
- [ ] Consider WAF rules for ALB

## Backup & Recovery
- [ ] Set up EBS snapshot schedule
- [ ] Document recovery procedures
- [ ] Test restoration from snapshots
- [ ] Back up Terraform state to S3 with versioning

## Documentation
- [ ] Update team documentation with:
  - [ ] Elastic IP address
  - [ ] ALB DNS name
  - [ ] CircleCI project link
  - [ ] SSH connection instructions
  - [ ] Application access URLs
- [ ] Document deployment procedures
- [ ] Document rollback procedures

## Optimization
- [ ] Review CloudWatch metrics
- [ ] Adjust EC2 instance type if needed
- [ ] Configure auto-scaling (optional)
- [ ] Optimize Docker image size
- [ ] Enable Docker image caching in ECR

---

# PART 14: TROUBLESHOOTING

## CircleCI Build Failures

### Error: "Cannot authenticate to ECR"
**Solution**: Verify AWS credentials in CircleCI environment variables
```bash
aws ecr get-login-password --region us-east-1
```

### Error: "Cannot reach EC2 via SSH"
**Solutions**:
1. Verify `EC2_HOST` is set to Elastic IP
2. Check security group allows port 22
3. Verify EC2_SSH_PRIVATE_KEY is correctly set
4. Ensure EC2 is running:
   ```bash
   aws ec2 describe-instances
   ```

### Error: "Docker image not found in ECR"
**Solution**: Verify `build-and-push` job completed successfully
```bash
aws ecr describe-images --repository-name shopping-cart-ecom --region us-east-1
```

## EC2 Issues

### Application not accessible
**Check steps:**
1. Verify EC2 instance is running
2. Check security group rules (port 80, 443, 5000)
3. SSH into EC2 and check Docker:
   ```bash
   docker ps
   docker logs shopping-cart-app
   ```
4. Check Docker Compose status:
   ```bash
   docker-compose -f /deployment/path/docker-compose.yml ps
   ```
5. Check application configuration
6. Review application logs for errors

### Out of disk space
**Solution**:
```bash
# Clean up old Docker images
docker image prune -a

# Clean up old containers
docker container prune

# Check disk usage
df -h
```

## Terraform Issues

### "State lock" error
**Solution**: Usually resolves automatically, or manually unlock:
```bash
terraform force-unlock LOCK_ID
```

### Resource already exists
**Solution**: Either import existing resource or delete and recreate:
```bash
# Import existing resource
terraform import aws_instance.web_server i-1234567890abcdef0

# Or delete and recreate
terraform destroy -target=aws_instance.web_server
terraform apply
```

---

# PART 15: MONITORING & MAINTENANCE

## Check Application Health
```bash
# Via ALB
curl http://ALB_DNS_NAME/healthcheck

# Via Elastic IP
curl http://ELASTIC_IP:5000/healthcheck
```

## View Logs
```bash
# SSH into EC2
ssh -i key.pem ubuntu@ELASTIC_IP

# View Docker logs
docker logs shopping-cart-app

# View system logs
sudo journalctl -u docker -n 50
```

## Update Application
```bash
# Push new code to main branch
git push origin main

# CircleCI automatically rebuilds and deploys
# Monitor progress in CircleCI dashboard
```

## Scale Infrastructure
Edit `terraform.tfvars` and redeploy:
```bash
terraform plan
terraform apply
```

## Rollback Procedures

### Quick Rollback (revert to previous Docker image)
```bash
ssh -i key.pem ubuntu@ELASTIC_IP
cd /deployment/path

# View Docker image history
docker images | grep shopping-cart-ecom

# Update docker-compose.yml to use previous image tag
docker-compose pull
docker-compose down
docker-compose up -d
```

### Full Rollback (revert code)
```bash
git revert HEAD --no-edit
git push origin main
# CircleCI will rebuild and redeploy previous version
```

### Infrastructure Rollback
```bash
cd terraform
terraform plan -destroy
terraform destroy
# Then reapply previous working state
```

## Performance Optimization Checklist

- [ ] Monitor EC2 CPU usage (target: < 70% average)
- [ ] Monitor memory usage (target: < 80% available)
- [ ] Monitor disk usage (target: > 20% free)
- [ ] Analyze ALB access logs
- [ ] Review CloudWatch metrics
- [ ] Optimize Docker image size
- [ ] Consider instance type upgrade if needed
- [ ] Enable caching where applicable
- [ ] Review database query performance

## Maintenance Schedule

### Daily
- [ ] Monitor application error logs
- [ ] Check ALB target health
- [ ] Monitor billing alerts

### Weekly
- [ ] Review CloudWatch metrics
- [ ] Check security alerts
- [ ] Test backup/restore procedure

### Monthly
- [ ] Review and update documentation
- [ ] Security audit of infrastructure
- [ ] Cost optimization review
- [ ] Update dependencies and patches
- [ ] Test disaster recovery plan

### Quarterly
- [ ] Full security audit
- [ ] Capacity planning review
- [ ] Update Terraform modules
- [ ] Review and optimize costs

---

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [CircleCI Documentation](https://circleci.com/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [AWS ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

---

**Created**: June 2026  
**Last Updated**: June 2026  
**Status**: Complete Infrastructure & Deployment Documentation
