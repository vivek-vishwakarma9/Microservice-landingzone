# 🏆 Holosport Enterprise Cloud Infrastructure (Azure)

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-Cloud_Platform-0078D4.svg?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5.svg?logo=kubernetes&logoColor=white)](https://azure.microsoft.com/en-us/products/kubernetes-service)
[![Security Scan](https://img.shields.io/badge/DevSecOps-Checkov_%7C_TFSec-E6522C.svg?logo=aquasecurity&logoColor=white)](https://www.checkov.io/)
[![CI/CD](https://img.shields.io/badge/Azure_DevOps-Pipelines-0078D7.svg?logo=azure-devops&logoColor=white)](https://azure.microsoft.com/en-us/products/devops/pipelines/)
[![Zero-Trust](https://img.shields.io/badge/Security-Zero--Trust_PrivateLink-009688.svg)](https://learn.microsoft.com/en-us/azure/private-link/)

> **Enterprise-Grade Infrastructure as Code (IaC)** for the Holosport microservices platform on **Microsoft Azure**. Engineered with modular Terraform, zero-trust network isolation (all PaaS public access disabled), automated DevSecOps pipelines (Checkov/TFSec), and scheduled daily drift governance.

---

## 📌 Table of Contents
- [Architecture Overview](#-architecture-overview)
- [Repository Structure](#-repository-structure)
- [Master Resource Inventory & Configuration](#-master-resource-inventory--configuration)
  - [1. Identity & Resource Management](#1-identity--resource-management)
  - [2. Virtual Networking & Subnets](#2-virtual-networking--subnets)
  - [3. Perimeter Security, Firewall & VPN](#3-perimeter-security-firewall--vpn)
  - [4. Kubernetes (AKS) & Container Platform](#4-kubernetes-aks--container-platform)
  - [5. Databases, Storage & PaaS (Zero-Trust)](#5-databases-storage--paas-zero-trust)
  - [6. Secrets Management & Master RBAC Matrix](#6-secrets-management--master-rbac-matrix)
- [Zero-Trust PrivateLink & DNS Architecture](#-zero-trust-privatelink--dns-architecture)
- [CI/CD & DevSecOps Automation (Azure DevOps)](#-cicd--devsecops-automation-azure-devops)
  - [Pipeline Stages](#pipeline-stages)
  - [Daily Drift Detection](#daily-drift-detection)
  - [Automated Stale Lock Auto-Recovery](#automated-stale-lock-auto-recovery)
- [Getting Started & Local Execution](#-getting-started--local-execution)
  - [Prerequisites](#prerequisites)
  - [Remote State Configuration](#remote-state-configuration)
  - [Terraform Execution Commands](#terraform-execution-commands)
- [Day-2 Operations & Runbooks](#-day-2-operations--runbooks)
- [Authors & Governance](#-authors--governance)

---

## 🏛️ Architecture Overview

The Holosport platform infrastructure is 100% codified using declarative HashiCorp Terraform modules. The architecture follows defense-in-depth principles:

1. **Zero-Trust Network Perimeter:** All enterprise PaaS data layers (PostgreSQL Flexible Server, Cosmos DB, Key Vault, Storage Accounts) have **Public Network Access explicitly DISABLED**. Data transfer occurs strictly via internal **Azure Private Endpoints (PrivateLink)**.
2. **Containerized Workloads:** Enterprise **Azure Kubernetes Service (AKS)** deployed with Azure CNI, managed identity federation, and `azurefile-csi` (ReadWriteMany) support for zero-downtime microservices deployments.
3. **Secure Remote Ingress:** Developers and DevOps runners access resources via **Point-to-Site (P2S) VPN Gateway** backed by Microsoft Entra ID (Azure AD) MFA, alongside browser-based **Azure Bastion**.
4. **DevSecOps & Automated Governance:** Continuous code validation via `tflint`, `tfsec`, **Checkov SAST (Policy-as-Code)**, `Infracost` spend forecasting, and **Automated Daily Drift Detection** (midnight schedule).

---

## 📂 Repository Structure

```text
c:\holosport
├── .gitignore                          # Standard Terraform & OS ignores
├── azure-pipelines.yml                 # Production 4-stage Azure DevOps CI/CD pipeline
├── environments/
│   └── dev/                            # Development environment root
│       ├── 01_core_identity.tf         # Resource Groups, User Assigned Identities, Random Passwords
│       ├── 02_networking.tf            # VNets, Subnets, NSGs, VPN Gateway, Firewall, Bastion
│       ├── 03_compute_workloads.tf     # AKS Cluster, ACR, Build Agent VMs, Function App
│       ├── 04_databases_storage.tf     # PostgreSQL Flexible, Cosmos DB, Key Vault, Storage, APIM
│       ├── 05_directories_pe_rbac.tf   # Private Endpoints, DNS links, Master RBAC matrix
│       ├── main.tf                     # Root coordinator and local tags
│       ├── outputs.tf                  # Exported outputs
│       ├── providers.tf                # azurerm, random, azuread provider declarations
│       ├── terraform.tfvars            # Declarative environment values
│       └── variables.tf                # Strongly typed variable schemas
├── modules/                            # 20 Reusable Child Modules
│   ├── azurerm_api_management/
│   ├── azurerm_bastion_host/
│   ├── azurerm_container_registry/
│   ├── azurerm_cosmosdb_account/
│   ├── azurerm_firewall/
│   ├── azurerm_key_vault/
│   ├── azurerm_key_vault_secret/
│   ├── azurerm_kubernetes_cluster/
│   ├── azurerm_linux_function_app/
│   ├── azurerm_network_security_group/
│   ├── azurerm_postgresql_flexible_server/
│   ├── azurerm_private_endpoint/
│   ├── azurerm_resource_group/
│   ├── azurerm_role_assignment/
│   ├── azurerm_storage_account/
│   ├── azurerm_user_assigned_identity/
│   ├── azurerm_virtual_network/
│   ├── azurerm_virtual_network_gateway/
│   └── azurerm_windows_virtual_machine/
└── tools/                              # Local dev security binaries (tflint, tfsec)
```

---

## 📊 Master Resource Inventory & Configuration

### 1. Identity & Resource Management

| Resource Name | Azure Type | Region | Purpose / Attached Workloads |
| :--- | :--- | :--- | :--- |
| `rg-eng-dev` | Resource Group | `East US` | Primary workload group hosting AKS, VNets, Databases, Key Vault, and VMs |
| `rg-eng-dev-tfstate` | Resource Group | `East US` | Dedicated container group hosting remote Terraform State blobs and lease locks |
| `uai-eng-dev-001` | User Assigned Managed Identity | `East US` | Scoped identity assigned to build runners (`AKS Admin`, `KV Secrets User`, `DocumentDB Contributor`) |

---

### 2. Virtual Networking & Subnets

The primary network architecture is configured on **`vnet-eng-dev-001`** (`10.0.0.0/16`) with internal custom DNS (`10.0.2.6`), accompanied by peered **`vnet-eng-dev-002`** (`10.1.0.0/16`).

| Subnet Name | CIDR Prefix | Associated Resources | Network Security Group (NSG) |
| :--- | :--- | :--- | :--- |
| `snet-aks` | `10.0.1.0/24` | AKS Cluster (`aks-eng-dev-001`) nodes & system pods | `nsg-aks-eng-dev-001` |
| `snet-workloads` | `10.0.2.0/24` | ADO Build Agent & GitHub Runners, DNS resolver | `nsg-workloads-eng-dev-001` |
| `AzureBastionSubnet` | `10.0.3.0/27` | Azure Bastion (`bst-eng-dev-001`) managed host | Managed by Platform |
| `GatewaySubnet` | `10.0.4.0/27` | Virtual Network Gateway (`vnetgw-eng-dev-001`) | Native VPN Routing |
| `AzureFirewallSubnet` | `10.0.5.0/26` | Azure Firewall (`afw-eng-dev-001`) data inspection | Managed by Platform |
| `AzureFirewallManagementSubnet` | `10.0.6.0/26` | Azure Firewall dedicated management plane | Managed by Platform |
| `snet-private-endpoints` | `10.0.7.0/24` | 6 Zero-Trust PaaS Private Endpoints | `nsg-pe-eng-dev-001` |
| `snet-secondary` | `10.1.1.0/24` | Secondary workload isolation subnet (`vnet-eng-dev-002`) | Default Isolation |

---

### 3. Perimeter Security, Firewall & VPN

* **Point-to-Site (P2S) VPN Gateway (`vnetgw-eng-dev-001`):**
  * **SKU / Tier:** `VpnGw1AZ` (Route-based)
  * **Protocols:** OpenVPN
  * **Authentication:** Microsoft Entra ID (Azure Active Directory) with MFA enforcement
  * **Client Pool:** `172.16.0.0/24` | **Custom DNS:** `10.0.2.6`
* **Azure Bastion (`bst-eng-dev-001`):**
  * **SKU:** `Basic` | Enables zero-public-IP browser-based RDP/SSH sessions for administrative jump access.
* **Azure Firewall (`afw-eng-dev-001`):**
  * **SKU:** `Basic` (`AZFW_VNet`)
  * **Network Rules:** Outbound TCP/UDP ports `80`, `443`, `53` permitted for internal VNet CIDR (`10.0.0.0/16`).
  * **Application Rules (FQDN Whitelist):** Dedicated egress permitted for DevOps platforms: `*.github.com`, `*.microsoft.com`, `*.azure.com`, `*.docker.com`, `*.docker.io`.

---

### 4. Kubernetes (AKS) & Container Platform

| Component | Resource Name | Specifications & Hardening |
| :--- | :--- | :--- |
| **AKS Cluster** | `aks-eng-dev-001` | • **SKU Tier:** Standard<br>• **Nodes:** 2x `Standard_D2s_v7` (2 vCPU, 8 GB RAM)<br>• **Network Plugin:** Azure CNI<br>• **Registry Link:** Managed Identity `AcrPull` on `acrengdev001`<br>• **Storage Class:** `azurefile-csi` (RWX support for zero-downtime rolling updates) |
| **Container Registry**| `acrengdev001` | • **SKU:** Premium<br>• **Admin Account:** DISABLED<br>• **Access:** RBAC-authenticated exclusively via Managed Identities & Private Endpoint |
| **ADO Build Agent** | `vm-eng-dev-ado-agent-001` | Windows VM (`Standard_F1as_v7`) with pre-installed `az CLI`, `kubectl`, and Azure DevOps pipelines agent |
| **GitHub Runners** | `vm-eng-dev-gh-runner-001`<br>`vm-eng-dev-gh-runner-002` | Dual self-hosted GitHub Actions runner instances (`Standard_F1as_v7`) in `snet-workloads` |
| **Serverless** | `func-eng-dev-001` | Linux Function App for event-driven async workloads backed by `stengdevfunc001` |

---

### 5. Databases, Storage & PaaS (Zero-Trust)

> 🛡️ **Zero-Trust Hardening:** All PaaS database and storage services have `public_network_access_enabled = false`. Direct internet access is completely blocked.

| Resource Name | Service Type | SKU / Engine | Public Access | Storage / Specs |
| :--- | :--- | :--- | :--- | :--- |
| `psql-eng-dev-001` | Azure Database for PostgreSQL Flexible Server | PostgreSQL 15 | ❌ **DISABLED** | `B_Standard_B1ms`, 32 GB Storage, SSL Enforced (`sslmode=require`) |
| `cosmos-eng-dev-001` | Azure Cosmos DB | SQL API (GlobalDocumentDB) | ❌ **DISABLED** | Standard Offer, PrivateLink secured |
| `stengdevfunc001` | Azure Storage Account | Standard LRS | ❌ **DISABLED** | Backend execution state for Linux Function App |
| `stengdevcontainerpool001`| Azure Storage Account | Standard LRS | ❌ **DISABLED** | Container volume shares & persistent pool storage |
| `apim-eng-dev-001` | Azure API Management (APIM) | `Basic_1` | VNet Integrated | System-Assigned Managed Identity enabled |

---

### 6. Secrets Management & Master RBAC Matrix

#### Dynamic Azure Key Vault Secrets (`kv-eng-dev-001`):
- `psql-admin-password`: 16-character high-entropy password generated dynamically via Terraform `random_password`.
- `cosmos-primary-key`: Master primary authentication key captured dynamically from Cosmos DB outputs.
- `vm-admin-password`: Secure administrator password generated dynamically for build runner virtual machines.

#### Azure RBAC Role Matrix:
| Principal Identity | Role Assigned | Scope Resource | Functional Purpose |
| :--- | :--- | :--- | :--- |
| **AKS Kubelet Identity** | `AcrPull` | `acrengdev001` (ACR) | Permits worker nodes to pull container images |
| **AKS Kubelet Identity** | `Key Vault Secrets User` | `kv-eng-dev-001` (KV) | Enables CSI Secret Provider to mount runtime secrets into pods |
| **Function App Identity** | `Key Vault Secrets User` | `kv-eng-dev-001` (KV) | Allows serverless runtime to retrieve DB/API credentials |
| **Function App Identity** | `Storage Blob Data Contributor` | `stengdevfunc001` | Grants runtime read/write access to state containers |
| **APIM Managed Identity** | `Key Vault Secrets User` | `kv-eng-dev-001` (KV) | Permits APIM to access backend mutual-TLS certificates |
| **Build Identity (`uai-eng-dev-001`)** | `Key Vault Secrets User` | `kv-eng-dev-001` (KV) | Enables automated CI runners to fetch deployment secrets |
| **Build Identity (`uai-eng-dev-001`)** | `AKS Cluster Admin Role` | `rg-eng-dev` (RG) | Grants CI/CD runners deployment authority over AKS workloads |
| **Build Identity (`uai-eng-dev-001`)** | `DocumentDB Contributor` | `rg-eng-dev` (RG) | Grants automated database schema migration permissions |
| **Build Identity (`uai-eng-dev-001`)** | `AKS Cluster User Role` | `rg-eng-dev` (RG) | Enables pipeline agents to read cluster state and logs |

---

## 🔒 Zero-Trust PrivateLink & DNS Architecture

Every managed PaaS resource terminates inside `snet-private-endpoints` (`10.0.7.0/24`) and maps directly to an Azure Private DNS Zone:

```
                  ┌────────────────────────────────────────────────────────┐
                  │                 vnet-eng-dev-001                       │
                  │             Custom DNS Resolver: 10.0.2.6              │
                  └───────────────────────────┬────────────────────────────┘
                                              │
                      ┌───────────────────────┴───────────────────────┐
                      ▼                                               ▼
         [ AKS Pods / Runners ]                            [ P2S VPN Clients ]
                      │                                               │
                      └───────────────────────┬───────────────────────┘
                                              │ (Resolves *.privatelink FQDNs)
                                              ▼
               ┌─────────────────────────────────────────────────────────────┐
               │         Subnet: snet-private-endpoints (10.0.7.0/24)        │
               ├────────────────────────┬────────────────────────────────────┤
               │ pe-kv-eng-dev-001      │ privatelink.vaultcore.azure.net    │
               │ pe-psql-eng-dev-spo-001│ privatelink.postgres.database.azure│
               │ pe-cosmos-eng-dev-spo01│ privatelink.documents.azure.com    │
               │ pe-st-eng-dev-001      │ privatelink.blob.core.windows.net  │
               │ pe-acr-eng-dev-001     │ privatelink.azurecr.io             │
               │ pe-aks-eng-dev-001     │ privatelink.eastus.azmk8s.io       │
               └─────────────────────────────────────────────────────────────┘
```

---

## 🚀 CI/CD & DevSecOps Automation (Azure DevOps)

The infrastructure pipeline (`azure-pipelines.yml`) provides enterprise continuous integration, security gating, and deployment:

```
[ Git Push / PR ] ──► [ Stage 1: Validate & Security Scans ]
                             ├── terraform fmt & validate
                             ├── TFLint (Code quality)
                             ├── TFSec (Security scanner)
                             └── Checkov SAST (Policy-as-Code)
                                           │
                                           ▼
                      [ Stage 2: Plan & Costing (Infracost) ]
                             ├── terraform plan (-detailed-exitcode)
                             ├── Infracost monthly budget report
                             └── Auto-recovery for stale state locks
                                           │
                                           ▼ (Approval Gate: eng-us-dev)
                      [ Stage 3: Apply Infrastructure ]
                             └── terraform apply (OIDC Auth)
```

### Pipeline Stages

1. **Stage 1: ValidateAndScan**
   - **Formatting & Syntax:** `terraform fmt -check` and `terraform validate`.
   - **Linting:** `tflint` across all child modules.
   - **Static Security Analysis:** `tfsec` scanning for compliance violations.
   - **Policy-as-Code SAST:** **`Checkov`** scans against CIS Azure benchmarks with automated JUnit XML result publishing.
2. **Stage 2: PlanAndCost**
   - **Remote Plan Generation:** Creates `eng-dev.tfplan` against remote Azure blob state using Workload Identity Federation (OIDC).
   - **Infracost Analysis:** Generates pull-request cost breakdowns before resources are provisioned.
3. **Stage 3: Apply**
   - Protected by Azure DevOps Environment approvals (`eng-us-dev`).
   - Executes `terraform apply -auto-approve eng-dev.tfplan` with zero interactive prompts.

### Daily Drift Detection
The pipeline runs an automated scheduled cron at **`00:00 UTC daily`** (`cron: "0 0 * * *"`):
```bash
terraform plan -detailed-exitcode -no-color
```
- **Exit Code 0:** Infrastructure in Azure is 100% in sync with code.
- **Exit Code 2:** Drift detected! Pipeline logs an issue warning alerting the DevOps team of unauthorized portal modifications.

### Automated Stale Lock Auto-Recovery
If a previous deployment is canceled midway and leaves an Azure Blob State Lease lock:
```bash
STALE_LOCK=$(grep -oP "ID:\s+\K[a-f0-9-]+" /tmp/plan_output.txt | head -n 1 || true)
if [ -n "$STALE_LOCK" ]; then
  terraform force-unlock -force "$STALE_LOCK"
fi
```

---

## 🛠️ Getting Started & Local Execution

### Prerequisites
- **Terraform:** v1.5.0 or higher
- **Azure CLI:** v2.50.0 or higher
- **TFLint & TFSec:** (Optional for local pre-commit verification)

### Remote State Configuration
The backend is stored securely in Azure Storage with Azure AD authentication:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-eng-dev-tfstate"
    storage_account_name = "<BACKEND_STORAGE_ACCOUNT>"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

### Terraform Execution Commands
```powershell
# 1. Login to Azure
az login
az account set --subscription "3f71298f-8bd4-4d7c-8020-98a79c24727e"

# 2. Navigate to dev environment
cd environments/dev

# 3. Initialize Terraform with remote backend
terraform init

# 4. Validate formatting and code syntax
terraform fmt -check
terraform validate

# 5. Generate plan
terraform plan -out=eng-dev.tfplan

# 6. Apply configuration (Requires DevOps authorization)
terraform apply "eng-dev.tfplan"
```

---

## 📖 Day-2 Operations & Runbooks

### 1. Connecting to AKS Cluster
Ensure you are connected to the Point-to-Site VPN or executing from `vm-eng-dev-ado-agent-001`:
```powershell
az aks get-credentials --resource-group rg-eng-dev --name aks-eng-dev-001 --admin
kubectl get nodes -o wide
kubectl get pods -A
```

### 2. Inspecting Zero-Downtime PVCs
```powershell
kubectl get sc
kubectl get pvc -n default
```
*(Verify storage class is `azurefile-csi` with access mode `ReadWriteMany`).*

### 3. Retrieving Key Vault Managed Secrets
```powershell
# Retrieve PostgreSQL Administrator Password
az keyvault secret show --vault-name kv-eng-dev-001 --name psql-admin-password --query value -o tsv

# Retrieve Cosmos DB Primary Key
az keyvault secret show --vault-name kv-eng-dev-001 --name cosmos-primary-key --query value -o tsv
```

### 4. Developer Onboarding (P2S VPN Access)
1. Install **Azure VPN Client** from the Microsoft Store.
2. Download VPN configuration profile generated from `vnetgw-eng-dev-001`.
3. Authenticate using corporate Microsoft Entra ID credentials with MFA.
4. Verify DNS resolution:
   ```powershell
   Resolve-DnsName psql-eng-dev-001.postgres.database.azure.com
   ```

---

## 👥 Authors & Governance

- **Lead DevOps Engineer:** Vivek Vishwakarma
- **Cloud Team:** Enterprise Cloud & Platform Engineering
- **Managed Under:** Engenio Inc / Holosport (AIONOS)
- **Review Cycle:** Automated Daily Drift & Weekly Pipeline Scan

---
*Maintained with ❤️ by the DevOps Team. For questions or change requests, please open an issue or pull request.*