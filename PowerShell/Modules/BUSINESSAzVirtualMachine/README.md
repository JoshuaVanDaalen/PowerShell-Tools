
Refer to the main README.md on using modules to run this module.

# Create a virtual machine
This module creates a Windows virtual machine.

```powershell
New-TallyAzVirtualMachine `
    -AzContextName  'dev' `
    -ResourceGroupName  'rg-virtualmachines-dev' `
    -VMName  'vmwin10box01' `
    -ResourcePrefix  'windows-development' `
    -VNetName  'vnet-aznet-auseast-dev' `
    -Location 'Australia Southeast'
    -Verbose
```

