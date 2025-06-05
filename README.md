# Infrastructure as Code (IaC) Test Files for Trivy

Thư mục này chứa các file IaC với các **misconfigurations** cố ý để test khả năng phát hiện lỗi cấu hình bảo mật của Trivy.

## Cấu trúc thư mục

```
iac/
├── terraform/          # Terraform configurations
│   ├── main.tf         # Main infrastructure with security issues
│   └── variables.tf    # Variables with hardcoded secrets
├── cloudformation/     # AWS CloudFormation templates
│   ├── template.yaml   # YAML template with misconfigurations
│   └── template.json   # JSON template with security issues
├── kubernetes/         # Kubernetes manifests
│   ├── deployment.yaml # Deployments with security vulnerabilities
│   └── misconfigured.yaml # Additional K8s resources with issues
├── docker/            # Docker configurations
│   ├── Dockerfile     # Dockerfile with security vulnerabilities
│   └── Dockerfile.webapp # Multi-stage Dockerfile with issues
├── helm/              # Helm charts
│   └── vulnerable-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           └── deployment.yaml
├── ansible/           # Ansible playbooks
│   ├── playbook.yml   # Playbook with security issues
│   └── inventory.ini  # Inventory with hardcoded credentials
├── azure-arm/         # Azure Resource Manager templates
│   ├── template.json  # ARM template with misconfigurations
│   └── parameters.json # Parameters file
└── README.md          # This file
```

## Các loại misconfigurations có trong files

### 🔴 Hardcoded Secrets
- Database passwords
- API keys
- JWT secrets
- SSH private keys
- SSL certificates

### 🔴 Insecure Configurations
- Running containers as root
- Overly permissive file permissions (777)
- Disabled encryption
- Public access to resources
- Weak authentication settings

### 🔴 Network Security Issues
- Open security groups (0.0.0.0/0)
- Disabled firewalls
- Insecure protocols (HTTP, Telnet, FTP)
- Host network mode in containers

### 🔴 Resource Misconfigurations
- No resource limits
- Missing backup configurations
- Disabled logging
- Weak SSL/TLS settings

## Cách sử dụng với Trivy

### 1. Scan toàn bộ thư mục IaC
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac
```

### 2. Scan từng loại IaC riêng biệt

#### Terraform
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/terraform
```

#### CloudFormation
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/cloudformation
```

#### Kubernetes
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/kubernetes
```

#### Docker
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/docker
```

#### Helm
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/helm
```

#### Ansible
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/ansible
```

#### Azure ARM
```bash
trivy config /Users/admin/Documents/fci/labs/demo/iac/azure-arm
```

### 3. Scan với options khác nhau

#### Chỉ hiển thị lỗi mức HIGH và CRITICAL
```bash
trivy config --severity HIGH,CRITICAL /Users/admin/Documents/fci/labs/demo/iac
```

#### Export kết quả ra file JSON
```bash
trivy config --format json -o results.json /Users/admin/Documents/fci/labs/demo/iac
```

#### Scan với template output
```bash
trivy config --format template --template "@template.tpl" /Users/admin/Documents/fci/labs/demo/iac
```

#### Scan với exit code (fail build nếu có issues)
```bash
trivy config --exit-code 1 /Users/admin/Documents/fci/labs/demo/iac
```

### 4. Scan các định dạng cụ thể
```bash
# Chỉ scan Terraform và Kubernetes
trivy config --misconfig-scanners terraform,kubernetes /Users/admin/Documents/fci/labs/demo/iac
```

## Các lỗi bảo mật mong đợi sẽ phát hiện

Trivy sẽ phát hiện các loại lỗi sau:
- **AVD-AWS-0086**: S3 bucket allows public read access
- **AVD-AWS-0124**: EC2 instance without encryption
- **AVD-AWS-0009**: Security group allows ingress from 0.0.0.0/0
- **KSV001**: Running container as root
- **KSV003**: Container without security context
- **KSV012**: Pod running with hostNetwork
- **DS002**: RUN using 'sudo' or 'su'
- **DS026**: No HEALTHCHECK defined

## Notes

⚠️ **Cảnh báo**: Các file trong thư mục này chứa các misconfigurations cố ý và **KHÔNG NÊN** được sử dụng trong môi trường production.

📊 **Mục đích**: Files này được tạo ra để:
- Test khả năng phát hiện misconfigurations của Trivy
- Học về các lỗi bảo mật phổ biến trong IaC
- Training và demo cho security scanning

🔧 **Trivy Version**: Tested với Trivy version 0.50.0 trở lên

## Thông tin thêm

- [Trivy Documentation](https://trivy.dev)
- [Trivy Config Scanning](https://trivy.dev/dev/docs/scanner/misconfiguration/)
- [Trivy Rules](https://trivy.dev/dev/docs/coverage/iac/)
