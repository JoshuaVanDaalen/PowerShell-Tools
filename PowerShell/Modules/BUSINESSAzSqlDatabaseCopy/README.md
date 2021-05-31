
Refer to the main README.md on using modules to run this module.

# Export database
Export a database into a storage account as a bacpac file.

```powershell
New-BUSINESSAzSqlDatabaseCopy `
     -TargetDatabaseName 'Org-Client-Prod' `
     -NewDatabaseName 'Org-Client-Sandbox'
```

