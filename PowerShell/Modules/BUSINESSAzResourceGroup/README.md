
Refer to the main README.md on using modules to run this module.

# Create a new resource group
Running this function creates a Azure resource group.


```powershell
New-BUSINESSAzResourceGroup `
    -AzContextName 'PROD' `
    -ResourceGroupName 'rg-BUSINESS-apps-linux' `
    -Approver 'Joshua Van Daalen' `
    -Environment 'Development' `
    -Owner 'Ken Ryskulov' `
    -Requestor 'Ken Ryskulov'
```
