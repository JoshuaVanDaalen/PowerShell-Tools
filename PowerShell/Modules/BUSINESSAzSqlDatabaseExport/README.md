
Refer to the main README.md on using modules to run this module.

# Export database
Export a database into a storage account as a bacpac file.

```powershell
New-BUSINESSAzSqlDatabaseExport `
        -ResourceGroupName 'rg-BUSINESS-internal-uat' `
        -ServerName 'sql-BUSINESS' `
        -DatabaseName 'Org-Dev-Client-Demo-zz' `
        -StorageAccountName 'stdbexport'
```

