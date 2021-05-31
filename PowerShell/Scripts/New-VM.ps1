
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Set subscription context to testing subscription
$devopstest001 = 'a626fa80-4bbc-4e8e-bc77-0b417f403913'
$Location = 'Australia Southeast'
##########################################################################################
#
Set-AzContext -SubscriptionId $devopstest001

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Creating Vpn groups for Azure AD auth on Vpn database
$randomNumber = (Get-Random).tostring().substring(0, 3)
$ADGroupOwner = Get-AzADUser -UserPrincipalName  'josh@domain.com.au'
$VMLocalAdminUser = "LocalAdminGuy"
$VMLocalAdminSecurePassword = ConvertTo-SecureString 'ToughPassword01' -AsPlainText -Force

$ResourceGroupName = "rg-devops-test-$randomNumber"
$ComputerName = "vmdevopstest$randomNumber"
$vmName = "vmdevopstest$randomNumber"
$VMSize = "Standard_B2s"

$NetworkName = "vnet-devops-southeastau-$randomNumber"
$NicName = "nic-devops-southeastau-$randomNumber"
$subnetName = "snet-devops-southeastau-$randomNumber"

$subnetName = "vgw-devops-internal-164-southeastau-$randomNumber"

$SubnetAddressPrefix = "10.0.0.0/24"
$VnetAddressPrefix = "10.0.0.0/16"


$SingleSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix $SubnetAddressPrefix

$Vnet = New-AzVirtualNetwork `
    -Name $NetworkName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -AddressPrefix $VnetAddressPrefix `
    -Subnet $SingleSubnet

$NIC = New-AzNetworkInterface `
    -Name $NICName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SubnetId $Vnet.Subnets[0].Id

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
# $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

$VirtualMachine = New-AzVMConfig `
    -VMName $VMName `
    -VMSize $VMSize

$VirtualMachine = Set-AzVMOperatingSystem `
    -VM $VirtualMachine `
    -Windows `
    -ComputerName $ComputerName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate

$VirtualMachine = Add-AzVMNetworkInterface `
    -VM $VirtualMachine `
    -Id $NIC.Id

$VirtualMachine = Set-AzVMSourceImage `
    -VM $VirtualMachine `
    -PublisherName 'MicrosoftWindowsServer' `
    -Offer 'WindowsServer' `
    -Skus '2019-Datacenter' `
    -Version 'latest'

New-AzVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -VM $VirtualMachine 
















#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Create resource group
##########################################################################################
#
New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Tag @{Approver = 'Ewen Stewart'; `
        Environment = "DevOps"; `
        Owner       = 'Joshua Van Daalen'; `
        Requestor   = 'Joshua Van Daalen';
}


# Create a new storage account
$StorageAccountName = 'stdevopstest01'
$SkuName = "Standard_LRS"

$StorageAccount = `
    New-AzStorageAccount `
    -Location $Location `
    -ResourceGroupName $ResourceGroupName `
    -SkuName $SkuName `
    -Name $StorageAccountName

# Create variables to store the location and resource group names.
# Create variables to store the storage account name and the storage account SKU information
# Create variables to store the network information
$SourceAddressPrefix = '103.16.96.170'
$NetworkSecurityGroupName = 'nsp-sagex3-prod-001'
$subnetName = 'snet-prod-southeastau-001'
$VnetName = 'vnet-prod-southeastau-001'
$publicIpName = "pip-sagex3-prod-southeastau-$(Get-Random)"
$NicName = 'nic-sagex3-prod-southeastau-001'
# Create variables to store the virtual machine information
$vmName = 'vmx3v12prod001'
$vmSize = 'Standard_B2ms' #$62.11 Cost/Month (estimate)
$VMLocalAdminUser = "ThomasAdmin"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "~C0mplex1896" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);




Set-AzureRmCurrentStorageAccount `
    -StorageAccountName $storageAccountName `
    -ResourceGroupName $resourceGroupName

# Create subnet configuration
$subnetConfig = `
    New-AzureRmVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -AddressPrefix "10.0.1.0/24" `

# Create a virtual network
$vnet = `
    New-AzureRmVirtualNetwork `
    -Name $VnetName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -AddressPrefix "10.0.1.0/24" `
    -Subnet $subnetConfig 

# Create a public IP address and specify a DNS name
$pip = `
    New-AzureRmPublicIpAddress `
    -Name $publicIpName `
    -ResourceGroupName $ResourceGroupName `
    -AllocationMethod Static `
    -Location $location

# Create an inbound network security group rule for port 3389
$allowRDP = `
    New-AzureRmNetworkSecurityRuleConfig `
    -Name 'RDP' `
    -Description "Allow RDP from MPLS WAN" `
    -Access 'Allow' `
    -Protocol 'Tcp' `
    -Direction 'Inbound' `
    -Priority '100' `
    -SourceAddressPrefix $SourceAddressPrefix `
    -SourcePortRange '*' `
    -DestinationAddressPrefix '*' `
    -DestinationPortRange 3389

# $allowRDP = `
#     New-AzureRmNetworkSecurityRuleConfig `
#         -Name 'WWW' `
#         -Description "Open port 80" `
#         -Access 'Allow' `
#         -Protocol 'Tcp' `
#         -Direction 'Inbound' `
#         -Priority '100' `
#         -SourceAddressPrefix * `
#         -SourcePortRange '*' `
#         -DestinationAddressPrefix '*' `
#         -DestinationPortRange 80

# Create a network security group
$nsg = `
    New-AzureRmNetworkSecurityGroup `
    -Name $NetworkSecurityGroupName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SecurityRules $allowRDP
        

#Create Network Interface
$nic = `
    New-AzureRmNetworkInterface `
    -Name $NicName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $pip.Id `
    -NetworkSecurityGroupId $nsg.Id

# Create the VM configuration object
$VirtualMachine = `
    New-AzureRmVMConfig `
    -VMName $vmName `
    -VMSize $vmSize

$VirtualMachine = `
    Set-AzureRmVMOperatingSystem `
    -VM $VirtualMachine `
    -Windows `
    -ComputerName $vmName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate

$VirtualMachine = `
    Set-AzureRmVMSourceImage `
    -VM $VirtualMachine `
    -PublisherName 'MicrosoftWindowsServer' `
    -Offer 'WindowsServer' `
    -Skus '2019-Datacenter' `
    -Version 'latest'

# Sets the operating system disk properties on a VM.
$VirtualMachine = `
    Set-AzureRmVMOSDisk `
    -VM $VirtualMachine `
    -CreateOption FromImage `
    -DiskSizeInGB 256 | `
    Set-AzureRmVMBootDiagnostics `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $StorageAccountName `
    -Enable |`
    Add-AzureRmVMNetworkInterface `
    -Id $nic.Id

# Create the VM.
New-AzureRmVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -VM $VirtualMachine
        