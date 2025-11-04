# Multi-Stack Voting Application - AWS Deployment

A distributed microservices voting application deployed on AWS EC2 instances using Terraform and Ansible.

## 🏗️ Architecture

- **Instance A** (Public): Vote App (Port 8080) + Result App (Port 8081) + Bastion Host
- **Instance B** (Private): Redis + Worker Service  
- **Instance C** (Private): PostgreSQL Database

## 📋 Prerequisites

- AWS Account with CLI access
- Terraform 1.0+
- Ansible 2.9+
- SSH key pair

## 🚀 Quick Deployment

### 1. Infrastructure Setup

```bash
cd terraform
terraform init
terraform apply
```

### 2. Manual Configuration Required ⚠️
After Terraform completes, you MUST update the IP addresses in the Ansible playbooks:

In ansible/playbooks/deploy_instance_b.yml:

yaml
vars:
  postgres_host: "10.2.3.167"  # ← REPLACE with actual Instance C private IP
In ansible/playbooks/deploy_instance_a.yml:

yaml
vars:
  redis_host: "10.2.2.80"      # ← REPLACE with actual Instance B private IP
  postgres_host: "10.2.3.167"  # ← REPLACE with actual Instance C private IP
Get IPs from Terraform output:

bash
terraform output

### 3. Deploy Application
bash
cd ../ansible

### Deploy in correct order:
```bash
ansible-playbook -i hosts playbooks/install-docker-on-all.ym # Install Docker-Engine on all Intances
ansible-playbook -i hosts playbooks/healthcheckscripts.yml   # Copy Healthcheck Scripts into containers
ansible-playbook -i hosts playbooks/deploy_instance_c.yml    # PostgreSQL First EC2 Instance
ansible-playbook -i hosts playbooks/deploy_instance_b.yml    # Redis + Worker Second EC2 Instance
ansible-playbook -i hosts playbooks/deploy_instance_a.yml    # Vote + Result Last EC2 Instance
```

### 🌐 Access the Application
After deployment, access the applications at:

Vote App: http://[INSTANCE_A_PUBLIC_IP]:8080

Result App: http://[INSTANCE_A_PUBLIC_IP]:8081

### 🔧 Manual Steps Summary
1. Run terraform apply
2. Note the IPs from terraform output
3. Update IPs in Ansible playbooks
4. Run Ansible playbooks in order: C → B → A
5. Test the applications

### 🗑️ Cleanup
```bash
terraform destroy
```

### ⚠️ Known Issues
- Manual IP configuration required between Terraform and Ansible
- First-time deployment may require manual database schema creation
- Healthchecks may need manual intervention on initial setup
