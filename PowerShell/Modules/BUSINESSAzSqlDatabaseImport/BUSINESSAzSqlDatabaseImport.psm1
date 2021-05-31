#Requires –Modules Az
#Written by Joshua Van Daalen.
Function New-BUSINESSAzSqlDatabaseImport {
    <#
    .SYNOPSIS
    Export a database into a storage account as a bacpac file.

    .DESCRIPTION
    TODO:

    .EXAMPLE
    New-BUSINESSAzSqlDatabaseImport `
        $ResourceGroupName =  'rg-devops'
        $ServerName =  'sql-server-001'
        $DatabaseName =  'Org-UAT-Client-Import'
        $FileName =  'Org-UAT-Client-Export-20210201_1407.bacpac'
        $StorageAccountName =  'stdbexports'
        $Env =  'DEV'

    #>
    [cmdletBinding()]
    param(

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the resource group to store the bacpac file')]
        [String]
        $ResourceGroupName,

        [Parameter( Mandatory = $true, HelpMessage = 'Enter Name of the server you are importing into')]
        [String]
        $ServerName,

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the database you are importing')]
        [String]
        $DatabaseName,

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the bacpac file.')]
        [String]
        $FileName,

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the storage account to store the bacpac file')]
        [String]
        $StorageAccountName,

        [Parameter(Mandatory = $false, HelpMessage = 'PROD or DEV')]
        [ValidateSet('PROD', 'DEV', 'UAT', 'TEST')]
        [String] $Env = 'DEV'
    )

    BEGIN { }
    PROCESS {
        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ##########################################################################################
        Set-AzContext -ErrorAction Stop -SubscriptionId 'e59fad46-f6cc-48b0-8c20-0bc276c837f6'

        $DateTime = Get-Date
        $Hour = $DateTime.Hour.ToString()
        $Minute = $DateTime.Minute.ToString()
        $Day = $DateTime.Day.ToString()
        $Month = $DateTime.Month.ToString()
        $Year = $DateTime.Year.ToString()
        if ($Day.length -eq 1) { $Day = "0$Day" }
        if ($Month.length -eq 1) { $Month = "0$Month" }
        if ($Hour.length -eq 1) { $Hour = "0$Hour" }
        if ($Minute.length -eq 1) { $Minute = "0$Minute" }
        $TimeStamp = "$Year$Month$Day`_$Hour$Minute"

        $ResourceGroup = Get-AzResourceGroup `
            -ErrorAction 'Stop' `
            -Name $ResourceGroupName

        $StorageAccount = Get-AzStorageAccount `
            -ErrorAction 'Stop' `
            -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName

        $StorageAccountAccessKey = (Get-AzStorageAccountKey `
                -ErrorAction 'Stop' `
                -ResourceGroupName $ResourceGroupName `
                -AccountName $StorageAccount.StorageAccountName).value[0]

        $StorageContainer = Get-AzStorageAccount `
            -ErrorAction 'Stop' `
            -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName | Get-AzStorageContainer -ErrorAction 'Stop' `

        $StorageUri = ($StorageContainer | Where-Object { $_.Name -eq 'stdbexports' }).BlobContainerClient.Uri.AbsoluteUri

        $Var = @{
            ServerName     = $ServerName
            DatabaseName   = "$DatabaseName-$TimeStamp"
            StorageKeytype = 'StorageAccessKey'
            StorageKey     = $StorageAccountAccessKey
            StorageUri     = "$StorageUri/$FileName"
        }

        switch ($ServerName) {

            'sql-server-001' {
                $Var.AzContextName = 'DB sub'
                $Var.ResourceGroupName = 'rg-dbs'
                $Var.AdministratorLogin = 'sa'
            }
            'sql-BUSINESS-uat' {
                $Var.AzContextName = 'BUSINESS UAT'
                $Var.ResourceGroupName = 'rg-standard-uat'
                $Var.AdministratorLogin = 'sa'
            }
            'sql-BUSINESS-shared' {
                $Var.AzContextName = 'BUSINESS Shared'
                $Var.ResourceGroupName = 'rg-BUSINESS-shared'
                $Var.AdministratorLogin = 'sa'
            }
            Default { }
        }

        ##########################################################################################
        Set-BUSINESSAzContext -Env $Var.AzContextName

        $Parameters = @{
            'ResourceGroupName'          = $Var.ResourceGroupName
            'ServerName'                 = $Var.ServerName
            'DatabaseName'               = $Var.DatabaseName
            'StorageKeytype'             = $Var.StorageKeytype
            'StorageKey'                 = $Var.StorageKey
            'StorageUri'                 = $Var.StorageUri
            'AdministratorLogin'         = $Var.AdministratorLogin
            'AdministratorLoginPassword' = (Read-Host -AsSecureString -Prompt "Enter sa password for $ServerName")
            Edition                      = 'Standard'
            ServiceObjectiveName         = 'S3'
            DatabaseMaxSizeBytes         = 268435456000
        }

        $importRequest = New-AzSqlDatabaseImport @Parameters

        Write-Host -ForegroundColor Yellow 'Run the follwing command to get the Import status'
        Write-Host -ForegroundColor Yellow "Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $($importRequest.OperationStatusLink)"
        Write-Host -ForegroundColor Red "`n`nRun the following to attach the elastic pool, after the import is completed"
        '$elasticPool = Get-AzSqlElasticPool -ResourceGroupName ' + "$($Var.ResourceGroupName)" + ' -ServerName ' + "$($Var.ServerName)"
        'Set-AzSqlDatabase -ResourceGroupName ' + "$($Var.ResourceGroupName)" + ' -DatabaseName ' + "$($Var.DatabaseName)" + ' -ServerName ' + "$($Var.ServerName)" + ' -ElasticPoolName $elasticPool.ElasticPoolName'

        ##########################################################################################
        # Limitations https://docs.microsoft.com/en-us/azure/azure-sql/database/database-import?tabs=azure-powershell#limitations
        # Importing to a database in elastic pool isn't supported. You can import data into a single database and then move the database to an elastic pool.

        # Due to this limitation we imported the database as -ServiceObjectiveName S3, meaning that it's not attached to the elastic pool
        # We will not move the database into the elastic pool
        ##########################################################################################

        # Example:
        # $ResourceGroupName = 'rg-BUSINESS-public-uat'
        # $ServerName = 'sql-public-uat-99009223'
        # $DatabaseName  = 'Org-Client_Copy'

        # $elasticPool = Get-AzSqlElasticPool `
        #     -ResourceGroupName $ResourceGroupName `
        #     -ServerName $ServerName

        # Set-AzSqlDatabase `
        #     -ResourceGroupName $ResourceGroupName `
        #     -DatabaseName $DatabaseName `
        #     -ServerName $ServerName `
        #     -ElasticPoolName $elasticPool.ElasticPoolName

        ##########################################################################################

    }

    END {
    }
}
