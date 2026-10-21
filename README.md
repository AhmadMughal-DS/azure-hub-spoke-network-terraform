# Azure Hub-Spoke Network Topology (Terraform)

> Enterprise hub-spoke network on Azure: a central hub with Azure Firewall + Bastion, peered to workload spokes, with forced tunneling — provisioned with Terraform.
> **Author:** Muhammad Ahmad · **IaC:** Terraform · **Cloud:** Azure

![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-7B42BC?logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-VNet%20%7C%20Firewall%20%7C%20Bastion-0078D4?logo=microsoftazure&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📌 Overview

The standard **hub-spoke** pattern for segmenting workloads:

- A **hub VNet** hosts shared services: **Azure Firewall** (central egress/inspection) and **Azure Bastion** (secure RDP/SSH).
- Two **spoke VNets** hold workloads, **peered** to the hub.
- A **route table** on the spokes forces all outbound traffic (`0.0.0.0/0`) through the firewall.

This gives centralized security, logging, and controlled connectivity between environments.

## 🏗️ Architecture

> 🎨 **Interactive diagram (industry-standard icons):** [open in Lucid — page 11](https://lucid.app/lucidchart/3da75ce3-ea66-4296-81b3-00d20a60435b/edit)

```mermaid
flowchart TB
    subgraph Hub["Hub VNet 10.0.0.0/16"]
        FW[Azure Firewall]
        BAS[Azure Bastion]
    end
    subgraph S1["Spoke 1 VNet 10.1.0.0/16"]
        W1[Workload Subnet]
    end
    subgraph S2["Spoke 2 VNet 10.2.0.0/16"]
        W2[Workload Subnet]
    end

    S1 <-->|peering| Hub
    S2 <-->|peering| Hub
    W1 -->|0.0.0.0/0| FW
    W2 -->|0.0.0.0/0| FW
    FW --> Internet([Internet])
```

## 🚀 Deploy

```bash
cd terraform
az login
terraform init
terraform apply
```

## 🧹 Clean up

```bash
terraform destroy
```

## 💰 Cost note

**Azure Firewall and Bastion are premium, hourly-billed services.** This is a reference topology — destroy it when you're done demoing.

## 🔐 Production hardening (next steps)

- Add **Firewall Policy** with application/network rule collections.
- Add **Azure Monitor / diagnostic settings** on the firewall.
- Add a **VPN/ExpressRoute gateway** in the hub for hybrid connectivity.

---

*Built and maintained by **Muhammad Ahmad**.*
