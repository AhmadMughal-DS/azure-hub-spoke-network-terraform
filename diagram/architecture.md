# Architecture Diagram — Azure Hub-Spoke Network

## Lucid diagram

- **Master Lucid document (all 30 diagrams, icon style):** https://lucid.app/lucidchart/3da75ce3-ea66-4296-81b3-00d20a60435b/edit
- This project is **page 11** of that document.

## Lucid prompt (reusable)

```
Create an Azure network diagram titled "Azure Hub-Spoke Network Topology".
A central Hub VNet contains Azure Firewall and Azure Bastion. Two Spoke VNets (Spoke 1,
Spoke 2) each contain a workload subnet and are peered to the hub (bidirectional).
The spokes route 0.0.0.0/0 to the Azure Firewall, which egresses to the Internet.
Clean, professional Azure colors.
```

## Mermaid source

```mermaid
flowchart TB
    FW[Azure Firewall]
    BAS[Azure Bastion]
    W1[Spoke 1 Workload]
    W2[Spoke 2 Workload]
    Internet([Internet])
    W1 <-->|peering| FW
    W2 <-->|peering| FW
    W1 -->|0.0.0.0/0| FW
    W2 -->|0.0.0.0/0| FW
    FW --> Internet
    BAS -.secure access.-> W1
    BAS -.secure access.-> W2
```
