# Month 10: Cloud CLI Tools

## Learning Objectives
- Master command-line interfaces for major cloud providers
- Learn infrastructure as code (IaC) with Terraform or OpenTofu
- Understand cloud deployment and management patterns
- Create automation for cloud resource lifecycle
- Develop secure cloud access workflows

## Resources
- **Primary Tools**: 
  - [AWS CLI Documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
  - [Terraform/OpenTofu Documentation](https://opentofu.org/docs/) or [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- **Reference**: List of cloud tools in `terminal-cheatsheet.md`
- **Supplementary**: [Infrastructure as Code](https://www.terraform-best-practices.com/) best practices

## Week 1: AWS CLI Fundamentals

### Daily Practice (20-30 minutes)
- Practice AWS CLI commands for various services
- Create and manage resources via CLI
- Explore service-specific subcommands

### Assignments
1. **AWS CLI Setup**:
   - Configure credentials and profiles
   - Learn AWS CLI structure and syntax
   - Understand output formatting options
   
2. **EC2 Management**:
   - Launch and manage EC2 instances
   - Configure security groups and networking
   - Create and attach storage volumes
   
3. **S3 Operations**:
   - Create and manage buckets
   - Upload, download, and sync files
   - Configure object properties and permissions
   
4. **IAM and Security**:
   - Manage users, groups, and roles
   - Configure access policies
   - Generate and manage credentials

### Week 1 Project
**AWS Resource Manager**: Create a shell script that helps manage common AWS resources with simplified commands and safety checks.

## Week 2: Advanced Cloud CLI

### Daily Practice (20-30 minutes)
- Use AWS CLI for complex operations
- Create multi-step cloud workflows
- Practice cloud resource monitoring

### Assignments
1. **Database Services**:
   - Manage RDS instances
   - Configure DynamoDB tables
   - Perform backup and restore operations
   
2. **Serverless Computing**:
   - Deploy and manage Lambda functions
   - Configure API Gateway endpoints
   - Set up event triggers and schedules
   
3. **Container Services**:
   - Work with ECR repositories
   - Manage ECS tasks and services
   - Deploy container applications
   
4. **Monitoring and Logging**:
   - Use CloudWatch from CLI
   - Retrieve and filter logs
   - Create and manage alarms

### Week 2 Project
**Serverless Deployment Tool**: Create a CLI tool that simplifies the deployment and management of serverless applications in AWS.

## Week 3: Infrastructure as Code with Terraform/OpenTofu

### Daily Practice (20-30 minutes)
- Write and apply Terraform configurations
- Refactor infrastructure code for reusability
- Practice state management and collaboration

### Assignments
1. **Terraform Fundamentals**:
   - Learn HCL syntax and structure
   - Understand providers and resources
   - Master init, plan, and apply workflow
   
2. **Resource Configuration**:
   - Define compute, storage, and networking resources
   - Learn input variables and outputs
   - Use data sources for existing resources
   
3. **Modules and Reusability**:
   - Create reusable Terraform modules
   - Implement module composition
   - Manage module versioning
   
4. **State Management**:
   - Understand Terraform state
   - Configure remote state backends
   - Learn state locking and collaboration

### Week 3 Project
**Infrastructure Module Library**: Create a collection of reusable Terraform/OpenTofu modules for common infrastructure patterns you use.

## Week 4: Multi-Cloud Management

### Daily Practice (20-30 minutes)
- Practice with CLI tools for different cloud providers
- Create provider-agnostic scripts
- Implement multi-cloud deployment patterns

### Assignments
1. **Multi-Cloud Strategies**:
   - Learn trade-offs of multi-cloud approaches
   - Understand abstraction patterns
   - Create provider-agnostic workflows
   
2. **Azure CLI Basics**:
   - Configure Azure CLI authentication
   - Learn command structure and patterns
   - Manage basic Azure resources
   
3. **GCP CLI Basics**:
   - Set up gcloud CLI authentication
   - Learn command structure and patterns
   - Manage basic GCP resources
   
4. **Cloud Management Abstraction**:
   - Create provider-agnostic scripts
   - Learn multi-cloud Terraform patterns
   - Implement common interfaces

### Week 4 Project
**Cloud Manager Dashboard**: Create a CLI dashboard that provides unified management for resources across multiple cloud providers.

## Month 10 Project: Complete Cloud Management Suite

**Objective**: Build a comprehensive cloud management toolkit that streamlines your infrastructure operations across providers.

**Requirements**:
1. CLI tools for managing resources in your preferred cloud providers
2. Infrastructure as Code templates for common patterns
3. Deployment automation for your applications
4. Cost monitoring and optimization tools
5. Security compliance checking scripts

**Deliverables**:
- Cloud management script collection
- Terraform/OpenTofu module library
- Deployment automation pipeline
- Cost analysis and reporting tool
- Security audit scripts

## Assessment Criteria
- Cloud CLI tool proficiency
- Infrastructure as Code quality
- Automation effectiveness
- Cost management approach
- Security implementation

## Suggested Daily Routine
1. 10 minutes reviewing cloud concepts
2. 15 minutes practicing with cloud CLIs
3. 20-30 minutes developing infrastructure code
4. 5 minutes documenting cloud management procedures
