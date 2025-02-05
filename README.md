# Azure Deployment and Networking Guide

## Objective

This guide provides a step-by-step tutorial to set up a secure virtual network in Azure, create subnets, configure security rules, deploy a virtual machine (VM), and establish secure access via Azure Bastion. Additionally, a load balancer is configured for traffic distribution.

## Prerequisites

- **Azure CLI** must be installed on your system.
- **PowerShell** is required to execute the provided script.
- **An active Azure subscription**.
- **Login to Azure** using the following command before running any script:
  ```powershell
  az login
  ```

## Description

### 1. Create an Azure Resource Group

A **Resource Group** acts as a container to manage and organize all related Azure resources efficiently.

### 2. Configure a Virtual Network and Subnets

A **Virtual Network (VNet)** is created with two subnets:
- **SegmentA (Subnet 1)**
- **SegmentB (Subnet 2)**

### 3. Implement Network Security Rules

A **Network Security Group (NSG)** is deployed to control inbound and outbound traffic:
- **Blocks SSH access (port 22)** for security.
- **Allows HTTP traffic (port 80)** for web services.
- The security group is attached to **SegmentA**.

### 4. Create a Public IP Address

A **Public IP** is allocated for external access.

### 5. Deploy Azure Bastion for Secure VM Access

- A dedicated **Azure Bastion subnet** is created.
- A **Public IP for Bastion** is assigned.
- **Azure Bastion service** is deployed to enable secure VM connectivity without exposing SSH.

### 6. Deploy a Virtual Machine (VM)

- A **Linux-based VM (Ubuntu 24.04)** is provisioned.
- The VM is placed in **SegmentA**.
- SSH keys are generated automatically for secure login.

### 7. Verify Security Settings

- Test **Bastion connectivity** via the Azure Portal.
- Confirm **SSH blocking** using Azure Cloud Shell:
  ```sh
  nc -zv <VM private IP> 22
  ```

### 8. Configure Load Balancer

- A **Load Balancer** is deployed to distribute traffic.
- A **frontend pool** and **backend pool** are created.
- The public IP address is assigned to the load balancer.

## Running the Script

Execute the PowerShell script to automate the setup:
```powershell
.\custom_azure_setup.ps1
```

## Additional Notes

- The manual execution steps are documented separately.
- Security settings ensure the VM is accessible only through Bastion.
- The Load Balancer helps in distributing web traffic efficiently.

