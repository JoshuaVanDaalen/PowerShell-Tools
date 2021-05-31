
Refer to the main README.md on using modules to run this module.

# Create a new Virtual Network
Running this function creates a Azure VNet with one subnet.

```powershell
New-TallyAzVirtualNetwork `
     -AzContextName 'devops-test-001' `
     -ResourceGroupName 'rg-devops-pwsh' `
     -VirtualNetworkName 'vnet-devops-001' `
     -AddressPrefix '10.0.0.0/16' `
     -SubnetName 'snet-devops-001' `
     -SubnetAddressPrefix '10.0.0.0/24'
```

