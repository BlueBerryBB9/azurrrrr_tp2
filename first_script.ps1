# Define custom variables
$rgName = "Pool2ResourceGroup2"
$region = "uksouth"
$vnetID = "CustomVNet"
$netSeg1 = "SegmentA"
$netSeg2 = "SegmentB"
$securityGroup = "CustomNSG"
$publicIPLabel = "CustomPublicIP"
$gatewayName = "CustomBastion"
$instanceName = "CustomVM"
$balancerName = "CustomLoadBalancer"

# Enable automatic extension installation
Write-Host "Enabling automatic extension installation..."
az config set extension.use_dynamic_install=yes_without_prompt

# Set up a new resource group
Write-Host "Initializing resource group..."
az group create --name $rgName --location $region

# Establish a virtual network with two network segments
Write-Host "Configuring virtual network and subnets..."
az network vnet create --resource-group $rgName --name $vnetID --address-prefix "10.1.0.0/16" --subnet-name $netSeg1 --subnet-prefix "10.1.1.0/24"
az network vnet subnet create --resource-group $rgName --vnet-name $vnetID --name $netSeg2 --address-prefix "10.1.2.0/24"

# Implement a security policy
Write-Host "Deploying security group..."
az network nsg create --resource-group $rgName --name $securityGroup

# Restrict SSH access
Write-Host "Restricting SSH access on port 22..."
az network nsg rule create --resource-group $rgName --nsg-name $securityGroup --name BlockSSH --protocol Tcp --direction Inbound --priority 100 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 22 --access Deny

# Allow HTTP traffic
Write-Host "Allowing web traffic on port 80..."
az network nsg rule create --resource-group $rgName --nsg-name $securityGroup --name AllowHTTP --protocol Tcp --direction Inbound --priority 200 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 80 --access Allow

# Link security group to a subnet
Write-Host "Applying security rules to the subnet..."
az network vnet subnet update --resource-group $rgName --vnet-name $vnetID --name $netSeg1 --network-security-group $securityGroup

# Verify security configurations
Write-Host "Confirming security group rules..."
az network nsg show --resource-group $rgName --name $securityGroup

# Allocate a public IP address
Write-Host "Allocating a public IP address..."
az network public-ip create --resource-group $rgName --name $publicIPLabel --sku Standard

# Establish a Bastion subnet
Write-Host "Creating a dedicated subnet for secure access..."
az network vnet subnet create --resource-group $rgName --vnet-name $vnetID --name AzureBastionSubnet --address-prefix "10.1.3.0/27"

# Allocate a public IP for Bastion
Write-Host "Assigning public IP to Bastion..."
$bastionIP = "CustomPublicIPBastion"
az network public-ip create --resource-group $rgName --name $bastionIP --sku Standard

# Deploy the Bastion service
Write-Host "Setting up Bastion for secure VM access..."
az network bastion create --resource-group $rgName --name $gatewayName --public-ip-address $bastionIP --vnet-name $vnetID --location $region

# Provision a new virtual machine
Write-Host "Launching virtual machine..."
az vm create --resource-group $rgName --name $instanceName --image Ubuntu2404 --vnet-name $vnetID --subnet $netSeg1 --admin-username azureuser --generate-ssh-keys

# Test Bastion connectivity manually through the Azure portal

# Check SSH restriction via Cloud Shell
# Use: nc -zv <VM private IP> 22 or telnet <VM private IP> 22

# Initialize a Load Balancer
Write-Host "Deploying a load balancer..."
az network lb create --resource-group $rgName --name $balancerName --sku Standard --frontend-ip-name FrontEndPool --backend-pool-name BackEndPool --public-ip-address $publicIPLabel
