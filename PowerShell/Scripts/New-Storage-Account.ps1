#Requires –Modules Az
# Stop script on first error
Set-StrictMode -Version Latest
$ErrorActionPreference = 'stop'

# Start Initial Variables 
$Var = @{
  # AzContextName     = 'devops-test-001'
  # AzContextName     = 'Dev'          # Development
  AzContextName     = 'Prod'  # Production
  # AzContextName     = 'UAT'                     # User Acdeptance Testing
  ResourceGroupName = 'tally-prod'
  AccountName       = 'stshared01'
  # Environment       = 'DEV' 
  # Environment       = 'devops' 
  # Environment       = 'PROD' 
  Environment       = 'PROD' 
  FirstName         = 'Joshua'
  LastName          = 'Van Daalen'
  Approver          = 'Joshua Van Daalen'
  Owner             = 'Joshua Van Daalen'
  # Location          = 'Australia Southeast'
  Location          = 'australiasoutheast'
  Requestor         = 'Some Guy'
}
$Tags = @{
  Approver    = $Var.Approver
  Environment = $Var.Environment
  Owner       = $Var.Owner
  Requestor   = $Var.Requestor
}
# End Initial Variables 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Set subscription context
##########################################################################################
Write-Output "Setting Azure Subscription Context"
# Get-AzContext -ListAvailable | Where-Object { $_.Subscription.Name -match $AzContextName } | Set-AzContext | Out-Null
Set-AzContext -SubscriptionId (Get-AzContext -ListAvailable | Where-Object { $_.Subscription.Name -match $Var.AzContextName }).Subscription.Id

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Create Storage Account
New-AzStorageAccount `
  -ResourceGroupName $Var.ResourceGroupName `
  -AccountName $Var.AccountName `
  -Location $Var.Location `
  -SkuName Standard_LRS `
  -Tag $Tags

##########################################################################################
