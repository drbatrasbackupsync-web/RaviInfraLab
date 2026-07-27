# Implementation Plan - Azure Infrastructure Verification & Security Enhancement

The objective is to audit and fix the existing Azure Terraform codebase (`frontend-vm` and `backend-vm`), incorporate missing enterprise components (**Azure Bastion**, **NAT Gateway**, and **Application Gateway**), enforce security best practices (isolating Backend VM from direct public access), and set up security/cost tools (**Infracost**, **TFSec**, **TFLint**, **Gitleaks**).

## User Review Required

> [!IMPORTANT]
> **Architecture Security Enhancements:**
> - **Backend VM Public IP Removal:** Backend VM will no longer have a public IP address. Internet egress for updates will route through **Azure NAT Gateway**, and SSH management access will route through **Azure Bastion**.
> - **Azure Bastion:** Dedicated `AzureBastionSubnet` (`10.0.3.0/24`) will be created for secure jump-host management without exposing SSH ports (22) to the public internet.
> - **Azure Application Gateway:** Dedicated `appgw-subnet` (`10.0.4.0/24`) will be added to route web traffic securely to the application tier.

> [!NOTE]
> **Tool Installation Options on Windows:**
> - Tools (`tflint`, `tfsec`, `infracost`, `gitleaks`) can be installed via **winget** or **Chocolatey** on Windows, or integrated into a **GitHub Actions CI workflow** / **PowerShell installation script**.

---

## Existing Code Analysis & Deficiencies Identified

1. **`azurerm_virtual_machine/main.tf`**:
   - Contains a hardcoded single `frontend-vm` resource referencing `azurerm_network_interface.main.id`, which does not exist in the module context (causes `terraform plan` failure).
   - Does not iterate over `var.vm-chor-dev` specified in `terraform.tfvars`.
   - Uses deprecated `azurerm_virtual_machine` resource instead of `azurerm_linux_virtual_machine`.
2. **`azurerm_public_ip/terraform.tfvars`**:
   - Defines a public IP for `pip-backend-dev-vm`, exposing the backend database/application VM directly to the internet (security risk).
3. **Missing Architectural Components**:
   - No **Azure Bastion** for management access.
   - No **Azure NAT Gateway** for secure backend egress.
   - No **Azure Application Gateway** for L7 load balancing and security.

---

## Proposed Changes

```
d:/Study/Practice/12_07_2026/module/dev/
├── azurerm_resource_group/
├── azurerm_virtual_network/
├── azurerm_subnet/
├── azurerm_public_ip/
├── azurerm_network_address/
├── azurerm_virtual_machine/
├── azurerm_bastion/          [NEW]
├── azurerm_nat_gateway/       [NEW]
├── azurerm_app_gateway/       [NEW]
└── scripts/
    └── install_security_tools.ps1 [NEW]
```

### 1. Networking & Subnet Subsystem

#### [MODIFY] [terraform.tfvars](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_subnet/terraform.tfvars)
Update subnets to include:
- `frontend`: `10.0.1.0/24`
- `backend`: `10.0.2.0/24`
- `AzureBastionSubnet`: `10.0.3.0/24` (Required exact naming for Azure Bastion)
- `appgw-subnet`: `10.0.4.0/24`

#### [MODIFY] [terraform.tfvars](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_public_ip/terraform.tfvars)
Configure public IPs for:
- `pip-frontend-dev-vm` (Frontend public IP)
- `pip-bastion-dev` (Bastion Host public IP)
- `pip-natgw-dev` (NAT Gateway outbound public IP)
- `pip-appgw-dev` (Application Gateway public IP)
- *(Remove standalone `pip-backend-dev-vm` to protect backend)*

---

### 2. Virtual Machine & NIC Subsystem

#### [MODIFY] [main.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_network_address/main.tf)
Update NIC resource logic:
- Connect `nic-frontend-vm` to `frontend-subnet` with optional frontend public IP.
- Connect `nic-backend-vm` to `backend-subnet` without any public IP assigned.

#### [MODIFY] [main.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_virtual_machine/main.tf)
Update VM creation to use `azurerm_linux_virtual_machine` with dynamic `for_each = var.vm-chor-dev`:
- Dynamically bind to existing NIC data sources (`data.azurerm_network_interface`).
- Configure SSH keys / administrative password security.

---

### 3. Azure Bastion Host Module

#### [NEW] [main.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_bastion/main.tf)
#### [NEW] [variable.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_bastion/variable.tf)
#### [NEW] [terraform.tfvars](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_bastion/terraform.tfvars)
- Resource: `azurerm_bastion_host`
- Binds to `AzureBastionSubnet` and `pip-bastion-dev`.

---

### 4. Azure NAT Gateway Module

#### [NEW] [main.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_nat_gateway/main.tf)
#### [NEW] [variable.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_nat_gateway/variable.tf)
#### [NEW] [terraform.tfvars](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_nat_gateway/terraform.tfvars)
- Resources: `azurerm_nat_gateway`, `azurerm_nat_gateway_public_ip_association`, `azurerm_subnet_nat_gateway_association`
- Associates NAT Gateway with `backend-subnet` for secure outbound internet connectivity.

---

### 5. Azure Application Gateway Module

#### [NEW] [main.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_app_gateway/main.tf)
#### [NEW] [variable.tf](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_app_gateway/variable.tf)
#### [NEW] [terraform.tfvars](file:///d:/Study/Practice/12_07_2026/module/dev/azurerm_app_gateway/terraform.tfvars)
- Resource: `azurerm_application_gateway`
- Standard_v2 / WAF_v2 SKU, HTTP/HTTPS frontend listener, backend address pool containing frontend/backend VMs.

---

### 6. Terraform Security & Cost Tooling Setup

#### [NEW] [install_security_tools.ps1](file:///d:/Study/Practice/12_07_2026/module/scripts/install_security_tools.ps1)
Automated PowerShell script to install and run:
- **TFLint**: Terraform linter for syntax and provider rules.
- **TFSec / Trivy**: Static analysis for security vulnerabilities and misconfigurations.
- **Infracost**: Cloud cost estimates directly from Terraform code.
- **Gitleaks / Tfleaks**: Secrets detection for credentials or private keys in `.tf` and `.tfvars` files.

#### [NEW] [.github/workflows/terraform-security.yml](file:///d:/Study/Practice/12_07_2026/module/.github/workflows/terraform-security.yml)
GitHub Actions CI pipeline to run `tflint`, `tfsec`, `gitleaks`, and `infracost` automatically on every commit/PR.

---

## Verification Plan

### Automated Tests & Scans
1. **Terraform Validation**: `terraform validate` across all module directories.
2. **Static Security Scanning**: Run `tfsec` / `trivy config .` to scan for compliance violations.
3. **Linting**: Run `tflint` to verify standard Azure provider practices.
4. **Secret Scanning**: Run `gitleaks detect --verbose` to ensure no sensitive passwords/keys are committed.
5. **Cost Estimation**: Run `infracost breakdown --path .` to generate cost breakdown.

### Manual Verification
1. Verify subnet structure matches Azure requirements (especially `AzureBastionSubnet`).
2. Verify Backend VM has `public_ip_address_id = null`.
3. Verify NAT Gateway subnet association maps to `backend-subnet`.
