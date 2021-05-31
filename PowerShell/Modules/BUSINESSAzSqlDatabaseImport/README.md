
Refer to the main README.md on using modules to run this module.

# Import database
Import a database from a bacpac file from a storage account.

## Note
Once the import is done you will need to attached the Elastic Pool manually as this is a limitation, see below.

```powershell
New-BUSINESSAzSqlDatabaseImport `
        -ServerName 'sql-public-uat-99009223' `
        -DatabaseName 'Org-Client-Import' `
        -StorageUri 'https://stdbexport.blob.core.windows.net/db-exports/Org-Client-zCopy-20200722_1814.bacpac' `
        -StorageAccountAccessKey 'BigLongTextStringFoundOnTheStorageAccountPageUnderAccessKeys=='
```

# Limitations
Importing to a database in elastic pool isn't supported.
You can import data into a single database and then move the database to an elastic pool.
Due to this limitation we imported the database as -ServiceObjectiveName S3, meaning that it's not attached to the elastic pool

Here is come code which will move the imported database into the elastic pool on the database server

```powershell
$elasticPool = Get-AzSqlElasticPool `
         -ResourceGroupName $ResourceGroupName `
         -ServerName $ServerName
         
Set-AzSqlDatabase `
         -ResourceGroupName $ResourceGroupName `
         -DatabaseName $DatabaseName `
         -ServerName $ServerName `
         -ElasticPoolName $elasticPool.ElasticPoolName
```
## Link 
https://docs.microsoft.com/en-us/azure/azure-sql/database/database-import?tabs=azure-powershell#limitations
