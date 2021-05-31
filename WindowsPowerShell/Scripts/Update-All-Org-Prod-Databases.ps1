
$Username = 'null'
$Passwd = $null
$DatabaseName = 'master'
$AzSqlServerFQDN = 'sql-name-here.database.windows.net'
[System.Collections.ArrayList]$DatabaseRecords = @{ }

$connectionString = "Server=tcp:$AzSqlServerFQDN,1433;" + `
  "Initial Catalog=$DatabaseName;" + `
  "Persist Security Info=False;" + `
  "User ID=$Username;" + `
  "Password=$Passwd;" + `
  "MultipleActiveResultSets=False;" + `
  "Encrypt=True;" + `
  "TrustServerCertificate=False;" + `
  "Connection Timeout=30;"

$dbList = ($MasterSession = Invoke-Sqlcmd -ConnectionString $connectionString -Query "SELECT * FROM SYS.DATABASES where name != 'master' order by name" ).name

foreach ($DatabaseName in $dbList) {

  $connectionString = "Server=tcp:$AzSqlServerFQDN,1433;" + `
    "Initial Catalog=$DatabaseName;" + `
    "Persist Security Info=False;" + `
    "User ID=$Username;" + `
    "Password=$Passwd;" + `
    "MultipleActiveResultSets=False;" + `
    "Encrypt=True;" + `
    "TrustServerCertificate=False;" + `
    "Connection Timeout=30;"

  $SqlUsersList = (Invoke-Sqlcmd `
      -ConnectionString $ConnectionString `
      -Query "SELECT * FROM SYS.DATABASE_PRINCIPALS where [name] like  'sql-%'").name
  # -Query "select is_rolemember('db_owner', 'sql-database-user-prod') as [db_owner]"   
  # -Query "select is_rolemember('db_owner', 'sql-database-owner-prod') as [db_owner]"
  # -Query "CREATE USER [sql-database-owner-prod] FROM EXTERNAL PROVIDER;"
  # -Query "ALTER ROLE db_owner ADD MEMBER [$SqlPowerUserGroupName]"
  # -Query "SELECT * FROM SYS.DATABASE_PRINCIPALS where [name] like  'sql-%'"

  foreach ($user in $SqlUsersList) {

    $SqlDbOwner = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "select is_rolemember('db_owner', '$user') as [db_owner]"   
        
    if ($user -like 'sql-database-owner*' ) {

      $dbOwnerProperties = @{      
        'isOwnerConfigured' = $SqlDbOwner.db_owner -eq 1 ? $true : $false
      }
    }

    if ($user -like 'sql-database-user*' ) {

      $userOwnerProperties = @{      
        'isUserMissConfigured' = $SqlDbOwner.db_owner -eq 1 ? $true : $false
      }
    }

    $dbOwnerPSObj = New-Object -TypeName PSObject -Property $dbOwnerProperties
    $userOwnerPSObj = New-Object -TypeName PSObject -Property $userOwnerProperties
    

    if ($User -like 'sql-database-user*') {

      $UserPermissions = Invoke-Sqlcmd `
        -ConnectionString $ConnectionString `
        -Query "SELECT USER_NAME(grantee_principal_id) [User],
        permission_name as [PermissionName],
        state_desc as [Permission]
        FROM sys.database_permissions
        WHERE USER_NAME(grantee_principal_id) = '$User'"
    
      $UserProperties = @{
        'PermissionName' = $UserPermissions.PermissionName
        'Permission'     = $UserPermissions.Permission
      }
        
      $UserPSObj = New-Object `
        -TypeName PSObject `
        -Property $UserProperties
    }
  }

  $Properties = @{
    'DatabaseName'         = $DatabaseName
    'Users'                = $Session.Name
    'isOwnerConfigured'    = $dbOwnerPSObj.isOwnerConfigured
    'isUserMissConfigured' = $userOwnerPSObj.isUserMissConfigured
    'UserPermissions'      = $UserPSObj.PermissionName
    'UserPerm'             = $UserPSObj.Permission
  }

  $PSObject = New-Object `
    -TypeName PSObject `
    -Property $Properties
      
  $DatabaseRecords.Add($PSObject)
    
}
    
$DatabaseRecords | Select-Object  DatabaseName, isOwnerConfigured, isUserMissConfigured, UserPermissions, UserPerm | Format-Table -AutoSize
