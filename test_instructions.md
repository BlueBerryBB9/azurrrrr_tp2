# Testing the Elements in the PowerShell Script for Azure Deployment

This document outlines how to test the various elements of the PowerShell script provided. The script involves creating resources such as virtual networks, security groups, Bastion services, virtual machines, and load balancers in Azure. Below are the steps to verify and validate that each element of the script is functioning as expected.

### 1. **Testing Custom Variables**

- **Variables to test**: `$rgName`, `$region`, `$vnetID`, `$netSeg1`, `$netSeg2`, `$securityGroup`, `$publicIPLabel`, `$gatewayName`, `$instanceName`, `$balancerName`.

**Test Method**:

- Ensure that these variables are defined and set with valid values.
- You can validate each variable using `Write-Host` to confirm that they are correctly set before running the actual resource creation commands.

Example:

```powershell
Write-Host "Resource Group: $rgName"
Write-Host "Region: $region"
Write-Host "VNet: $vnetID"
Write-Host "Subnet 1: $netSeg1"
Write-Host "Subnet 2: $netSeg2"
Write-Host "Security Group: $securityGroup"
Write-Host "Public IP Label: $publicIPLabel"
Write-Host "Bastion Gateway: $gatewayName"
Write-Host "VM Instance: $instanceName"
Write-Host "Load Balancer: $balancerName"
```

This will ensure that all variables are correctly initialized before deployment.

---

### 2. **Testing Resource Group Creation**

- **Command to test**:
  ```powershell
  az group create --name $rgName --location $region
  ```

**Test Method**:

- After running the command, check the Azure portal for the new resource group.
- Use the Azure CLI to verify:
  ```bash
  az group show --name $rgName
  ```

This command will display the resource group's details, ensuring it was successfully created.

---

### 3. **Testing Virtual Network Creation**

- **Command to test**:
  ```powershell
  az network vnet create --resource-group $rgName --name $vnetID --address-prefix "10.1.0.0/16" --subnet-name $netSeg1 --subnet-prefix "10.1.1.0/24"
  ```

**Test Method**:

- Verify the VNet and subnet creation using:

  ```bash
  az network vnet show --resource-group $rgName --name $vnetID
  ```

- Confirm that the subnets `netSeg1` and `netSeg2` are correctly listed under the VNet.

---

### 4. **Testing Security Group Creation and Rule Application**

- **Commands to test**:
  - Deploy security group:
    ```powershell
    az network nsg create --resource-group $rgName --name $securityGroup
    ```
  - Add rules to restrict SSH and allow HTTP:
    ```powershell
    az network nsg rule create --resource-group $rgName --nsg-name $securityGroup --name BlockSSH --protocol Tcp --direction Inbound --priority 100 --source-address-prefix "*" --destination-port-range 22 --access Deny
    az network nsg rule create --resource-group $rgName --nsg-name $securityGroup --name AllowHTTP --protocol Tcp --direction Inbound --priority 200 --source-address-prefix "*" --destination-port-range 80 --access Allow
    ```

**Test Method**:

- Confirm the security group and rules are correctly applied by checking the configuration:

  ```bash
  az network nsg show --resource-group $rgName --name $securityGroup
  ```

- You can also verify security rules through the Azure portal by checking the network security group associated with the resource group.

---

### 5. **Testing Virtual Machine (VM) Creation**

- **Command to test**:
  ```powershell
  az vm create --resource-group $rgName --name $instanceName --image Ubuntu2404 --vnet-name $vnetID --subnet $netSeg1 --admin-username azureuser --generate-ssh-keys
  ```

**Test Method**:

- Check the VM creation in the Azure portal under the specified resource group.
- You can also test the VM's connectivity by using SSH from the Azure portal or another terminal:
  ```bash
  ssh azureuser@<VM_public_ip>
  ```

---

### 6. **Testing Bastion Service**

- **Commands to test**:
  - Deploy Bastion:
    ```powershell
    az network bastion create --resource-group $rgName --name $gatewayName --public-ip-address $bastionIP --vnet-name $vnetID --location $region
    ```

**Test Method**:

- Test Bastion connectivity through the Azure portal by attempting to connect to the VM using the Bastion host.
- Confirm that the Bastion subnet exists by running:
  ```bash
  az network vnet subnet show --resource-group $rgName --vnet-name $vnetID --name AzureBastionSubnet
  ```

---

### 7. **Testing Load Balancer Creation**

- **Command to test**:
  ```powershell
  az network lb create --resource-group $rgName --name $balancerName --sku Standard --frontend-ip-name FrontEndPool --backend-pool-name BackEndPool --public-ip-address $publicIPLabel
  ```

**Test Method**:

- Verify that the load balancer was created in the Azure portal.
- You can also test the frontend and backend pool configurations:
  ```bash
  az network lb show --resource-group $rgName --name $balancerName
  ```

---

### 8. **Testing SSH Restrictions**

- **Command to test**:
  ```bash
  nc -zv <VM_private_ip> 22
  ```

**Test Method**:

- Run the above command from a Cloud Shell or another terminal to confirm that SSH access is blocked on port 22.
- You should receive a "connection refused" message, confirming the SSH restriction is effective.

---

### 9. **Testing HTTP Access**

- **Command to test**:
  ```bash
  curl http://<VM_public_ip>
  ```

**Test Method**:

- After ensuring the VM is up and running, confirm that HTTP traffic on port 80 is allowed by accessing the web service from a browser or using `curl`.
- The connection should succeed if the security group rules are correctly applied.
