#Requires –Modules Az
#Requires -Version 7.0
#Written by Joshua Van Daalen.
Function New-BUSINESSAzSqlDatabaseExport {
    <#
    .SYNOPSIS
    Export a database into a storage account as a bacpac file.

    .DESCRIPTION
    Before Starting the export you must do a AzSqlDatabaseCopy, then export the copied database.

    .EXAMPLE
    New-BUSINESSAzSqlDatabaseExport `
        -ResourceGroupName 'BUSINESSDBResources' `
        -ServerName 'sql-BUSINESS-uat' `
        -DatabaseName 'Org-UAT-Client-Export' `
        -StorageAccountName 'BUSINESSdbstorage' `
        -Env 'UAT'
    #>
    [cmdletBinding()]
    param(

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the resource group to store the bacpac file')]
        [String]
        $ResourceGroupName,

        [Parameter( Mandatory = $true, HelpMessage = 'Enter Name of the server you are exporting from')]
        [String]
        $ServerName,

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the database you are exporting')]
        [String]
        $DatabaseName,

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the storage account to store the bacpac file')]
        [String]
        $StorageAccountName,

        [Parameter(Mandatory = $false, HelpMessage = 'PROD or DEV')]
        [ValidateSet('PROD', 'DEV', 'UAT', 'TEST')]
        [String] $Env = 'DEV'
    )

    BEGIN {

        #Hardcoded for BUSINESSdbstorage in DB subscription > RG BUSINESSDBResources
        # Set-BUSINESSAzContext -Env 'DB'
        Set-AzContext -ErrorAction Stop -SubscriptionId '81133a5a-064e-4bfb-8c61-3ce83c2bc88a'


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
            -Name $StorageAccountName | Get-AzStorageContainer -ErrorAction 'Stop'

        $StorageUri = ($StorageContainer | Where-Object { $_.Name -eq 'dbexports' }).BlobContainerClient.Uri.AbsoluteUri

        $Var = @{
            ServerName     = $ServerName
            DatabaseName   = $DatabaseName
            StorageKeytype = 'StorageAccessKey'
            StorageKey     = $StorageAccountAccessKey
            StorageUri     = "$StorageUri/$DatabaseName-$TimeStamp.bacpac"
        }

        switch ($ServerName) {

            'sql-SERVER-prod' {
                $Var.AzContextName = 'DB Services'
                $Var.ResourceGroupName = 'BUSINESSDBResources'
                $Var.AdministratorLogin = 'sa'
            }
            'sql-BUSINESS-uat' {
                $Var.AzContextName = 'BUSINESSPreProduction'
                $Var.ResourceGroupName = 'rg-standard-uat'
                $Var.AdministratorLogin = 'sa'
            }
            'sql-BUSINESS-shared' {
                $Var.AzContextName = 'BUSINESSSharedServices'
                $Var.ResourceGroupName = 'rg-BUSINESS-shared'
                $Var.AdministratorLogin = 'sa'
            }
            Default { }
        }

        Set-BUSINESSAzContext -Env $Var.AzContextName

    }
    PROCESS {
        ##########################################################################################
        $Parameters = @{
            'ErrorAction'                = 'Stop'
            'ResourceGroupName'          = $Var.ResourceGroupName
            'ServerName'                 = $Var.ServerName
            'DatabaseName'               = $Var.DatabaseName
            'StorageKeytype'             = $Var.StorageKeytype
            'StorageKey'                 = $Var.StorageKey
            'StorageUri'                 = $Var.StorageUri
            'AdministratorLogin'         = $Var.AdministratorLogin
            'AdministratorLoginPassword' = (Read-Host -AsSecureString -Prompt "Enter sa password for $ServerName")
        }

        $Parameters
        $exportRequest = New-AzSqlDatabaseExport @Parameters

        Write-Host -ForegroundColor Green 'Run the follwing command to get the Export status'
        Write-Host -ForegroundColor Yellow "Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $($exportRequest.OperationStatusLink)"
    }

    END {
    }
}
