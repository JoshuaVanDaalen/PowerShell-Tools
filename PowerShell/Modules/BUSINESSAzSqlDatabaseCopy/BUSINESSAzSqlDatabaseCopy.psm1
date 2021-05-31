#Requires –Modules Az
#Requires -Version 7.0
#Written by Joshua Van Daalen.
Function New-BUSINESSAzSqlDatabaseCopy {
    <#
    .SYNOPSIS
    Copy a database.

    .DESCRIPTION
    This works only when both databases are on the same SQL server.

    .EXAMPLE
    New-BUSINESSAzSqlDatabaseCopy

    .EXAMPLE
    New-BUSINESSAzSqlDatabaseCopy `
        -TargetDatabaseName 'Org-UAT-Client' `
        -NewDatabaseName 'Org-UAT-Client-Export' `
        -Env 'UAT'
    #>
    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the database you wish to copy')]
        [String] $TargetDatabaseName,

        [Parameter(Mandatory = $true, HelpMessage = 'Enter Name of the new database')]
        [String] $NewDatabaseName,

        [Parameter(Mandatory = $false, HelpMessage = 'PROD or DEV')]
        [ValidateSet('PROD', 'DEV', 'UAT')]
        [String] $Env = 'DEV'
    )

    begin {
        $Var = @{
            ResourceGroupName     = $Env.ToUpper() -eq 'UAT' ? 'rg-standard-uat' : 'BUSINESSDBResources'
            CopyResourceGroupName = $Env.ToUpper() -eq 'UAT' ? 'rg-standard-uat' : 'BUSINESSDBResources'
            ServerName            = $Env.ToUpper() -eq 'UAT' ? 'sql-BUSINESS-uat' : 'sql-server-prod'
            CopyServerName        = $Env.ToUpper() -eq 'UAT' ? 'sql-BUSINESS-uat' : 'sql-server-prod'
            Env                   = $Env.ToUpper() -eq 'UAT' ? 'UAT' : 'DB'
            ElasticPoolName       = $Env.ToUpper() -eq 'UAT' `
                ? 'sqlpool-BUSINESS-uat' `
                : $Env.ToUpper() -eq 'DEV' `
                ? 'sqlpool-BUSINESS-dbpool-dev-001' `
                : 'sql-server-prod-dbpool'
        }
        Set-BUSINESSAzContext -Env $Var.Env
    }
    PROCESS {

        $Parameters = @{
            ResourceGroupName     = $Var.ResourceGroupName
            CopyResourceGroupName = $Var.CopyResourceGroupName
            ServerName            = $Var.ServerName
            CopyServerName        = $Var.CopyServerName
            DatabaseName          = $TargetDatabaseName
            CopyDatabaseName      = $NewDatabaseName
            ElasticPoolName       = $Var.ElasticPoolName
            ErrorAction           = 'Stop'
        }

        Write-Host -ForegroundColor Yellow "Creating new database: $NewDatabaseName"
        New-AzSqlDatabaseCopy @Parameters

    }
    END { }
}
