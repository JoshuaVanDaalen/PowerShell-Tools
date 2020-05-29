#Requires –Modules Az

# Start Initial variables 
$Var = @{
  AzContextName         = 'Database Subscription'
  ResourceGroupName     = 'rg-source'
  CopyResourceGroupName = 'rg-copy'
  ServerName            = 'sql-source'
  CopyServerName        = 'sql-copy'
  DatabaseName          = 'sqldb-source' 
  CopyDatabaseName      = 'sqldb-copy'
}
# If the server has an elastic pool set this value, otherwise leave it as an empty string
$ElasticPoolName = "$ServerName-dbpool-001"
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
    -ListAvailable | Where-Object { $_.Subscription.Name -match $AzContextName }
  
  Set-AzContext `
    -ErrorAction 'Stop' `
    -ErrorVariable 'setAzContext' `
    -SubscriptionId $AzContext.Subscription.Id

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Create Production database    
  $Parameters = @{
    ResourceGroupName     = $Var.ResourceGroupName
    CopyResourceGroupName = $Var.CopyResourceGroupName
    ServerName            = $Var.ServerName
    CopyServerName        = $Var.CopyServerName
    DatabaseName          = $Var.DatabaseName
    CopyDatabaseName      = $Var.CopyDatabaseName
    ErrorAction           = 'Stop'
    ErrorVariable         = 'prodAzSqlDatabaseCopy'
  }
  $Parameters.ElasticPoolName = $ElasticPoolName.Length -eq 0 ? '' : $ElasticPoolName

  ##########################################################################################

  New-AzSqlDatabaseCopy @Parameters

  ##########################################################################################
  # Create Development database
  $Parameters.DatabaseName = $Var.CopyDatabaseName
  $Parameters.CopyDatabaseName = $Var.CopyDatabaseName + "-dev"
  $Parameters.ErrorVariable = "devAzSqlDatabaseCopy"
  ##########################################################################################

  New-AzSqlDatabaseCopy @Parameters
}
Catch {
  if ($prodAzSqlDatabaseCopy) { Write-Host -ForegroundColor Red "$prodAzSqlDatabaseCopy" }
  if ($devAzSqlDatabaseCopy) { Write-Host -ForegroundColor Red "$devAzSqlDatabaseCopy" }
}
