#Requires –Modules Az
# Stop script on first error
Set-StrictMode -Version Latest
$ErrorActionPreference = 'stop'

# Start Initial Variables 
$Var = @{
  AzContextName     = 'PROD'
  Environment       = 'PROD' 
  ResourceGroupName = 'source' # This value changes to rg-source-prod
  Approver          = 'Joshua Van Daalen'
  Owner             = 'Joshua Van Daalen'
  Requestor         = 'Joshua Van Daalen'
  Contributor       = "josh@domain.com.au"
  Location          = 'Australia Southeast'
}
# End Initial Variables 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Set subscription context
##########################################################################################
Write-Output "Setting Azure Subscription Context"
Set-AzContext -SubscriptionId (Get-AzContext -ListAvailable | Where-Object { $_.Subscription.Name -match $Var.AzContextName }).Subscription.Id

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Create resource group
$FullResourceGroupName = "rg-$($Var.ResourceGroupName)-$($Var.Environment)".ToLower()
$Tags = @{
  Approver    = $Var.Approver
  Environment = $Var.Environment
  Owner       = $Var.Owner
  Requestor   = $Var.Requestor
}
##########################################################################################

New-AzResourceGroup `
  -ErrorAction 'Stop' `
  -Name $FullResourceGroupName `
  -Location $Var.Location `
  -Tag $Tags

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Set role permissions on Resourece Group
##########################################################################################

New-AzRoleAssignment `
  -ResourceGroupName  $FullResourceGroupName `
  -SignInName $Var.Contributor `
  -RoleDefinitionName 'Contributor'
