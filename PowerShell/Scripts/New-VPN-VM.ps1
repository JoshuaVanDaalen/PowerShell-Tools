#Requires –Modules Az

# Start Initial variables 
$AzContext = 'Sandbox'

# End Initial variables 

Try {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Set subscription context
  ##########################################################################################
  $AzContext = `
    Get-AzContext `
    -ErrorAction 'Stop' `
    -ErrorVariable 'getAzContext' `
    -ListAvailable | Where-Object { $_.Subscription.Name -match $AzContext }
  
  Set-AzContext `
    -ErrorAction 'Stop' `
    -ErrorVariable 'setAzContext' `
    -SubscriptionId $AzContext.Subscription.Id
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Create resource group
  # $randomNumber = (Get-Random).tostring().substring(0, 3)
  $randomNumber = '17230'
  $resourcePrefix = 'vpn-public'
  $ResourceGroupName = "rg-$resourcePrefix-$randomNumber"
  $Location = 'Australia Southeast'
  ##########################################################################################

  New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Tag @{
      Approver = 'Joshua Van Daalen'; `
      Environment   = "Production"; `
      Owner         = 'Joshua Van Daalen'; `
      Requestor     = 'Joshua Van Daalen';
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Create subnet
  $subnetName = "snet-$resourcePrefix-$randomNumber"
  $SubnetAddressPrefix = "172.30.0.0/26"
  ##########################################################################################

  $SingleSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix $SubnetAddressPrefix

  ##########################################################################################
  # Create a virtual network
  $NetworkName = "vnet-$resourcePrefix-$randomNumber"
  $VnetAddressPrefix = "172.30.0.0/24"
  ##########################################################################################

  $Vnet = New-AzVirtualNetwork `
    -Name $NetworkName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -AddressPrefix $VnetAddressPrefix `
    -Subnet $SingleSubnet

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Create a public IP address
  $PublicIPAddressName = "pip-$resourcePrefix-$(Get-Random)"
  ##########################################################################################
  $PIP = New-AzPublicIpAddress `
    -Name $PublicIPAddressName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -AllocationMethod Dynamic

  ##########################################################################################
  #Create Network Interface
  $NicName = "nic-$resourcePrefix-$randomNumber"
  ##########################################################################################

  $NIC = New-AzNetworkInterface `
    -Name $NICName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SubnetId $Vnet.Subnets[0].Id `
    -PublicIpAddressId $PIP.Id `

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Create the VM configuration object
  $VMSize = "Standard_B2s"
  $ComputerName = "vmcentosvpn$randomNumber"
  ##########################################################################################
  # Set VM size
  $VirtualMachine = New-AzVMConfig `
    -VMName $ComputerName `
    -VMSize $VMSize

  ##########################################################################################
  # Set VM OS
  $VMLocalAdminUser = $env:vpnUsername
  $VMLocalAdminSecurePassword = ConvertTo-SecureString `
    -String $env:vpnSecret `
    -AsPlainText `
    -Force
  $Credential = New-Object `
    -TypeName System.Management.Automation.PSCredential `
    -ArgumentList ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
  ##########################################################################################

  $VirtualMachine = Set-AzVMOperatingSystem `
    -VM $VirtualMachine `
    -Linux `
    -ComputerName $ComputerName `
    -Credential $Credential `

  ##########################################################################################
  # Add NIC to VM
  ##########################################################################################
  $VirtualMachine = Add-AzVMNetworkInterface `
    -VM $VirtualMachine `
    -Id $NIC.Id

  ##########################################################################################
  # Set VM insatllation image
  ##########################################################################################
  $VirtualMachine = Set-AzVMSourceImage `
    -VM $VirtualMachine `
    -PublisherName 'center-for-internet-security-inc' `
    -Offer 'cis-centos-8-l1' `
    -Skus 'cis-centos8-l1' `
    -Version 'latest'

  ##########################################################################################
  # Create VM
  ##########################################################################################
  $LocationOther = 'australiasoutheast'
  New-AzVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $LocationOther `
    -VM $VirtualMachine 

}
Catch {
    
}