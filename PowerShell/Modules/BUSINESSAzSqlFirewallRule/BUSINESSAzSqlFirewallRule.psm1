BUSINESS#Requires –Modules Az
#Requires -Version 7.0
#Written by Joshua Van Daalen.
function Get-BUSINESSAzSqlFirewallRule {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Enter Description')]
        [String]
        $FirewallRuleName,

        [Parameter(HelpMessage = 'PROD or UAT?')]
        [ValidateSet('PROD', 'UAT')]
        [String]
        $Env = 'PROD'
    )

    begin {
        $Var = @{
            ResourceGroupName = $Env.ToUpper() -eq 'PROD' ? 'BUSINESSDBResources' : 'rg-standard-uat'
            ServerName        = $Env.ToUpper() -eq 'PROD' ? "BUSINESSit" : 'sql-BUSINESS-uat'
            Env               = $Env.ToUpper() -eq 'PROD' ? 'DB' : 'UAT'
        }
        Set-BUSINESSAzContext -Env $Var.Env
    }

    process {

        Get-AzSqlServerFirewallRule `
            -ResourceGroupName $Var.ResourceGroupName `
            -ServerName $Var.ServerName |
            Where-Object { $_.FirewallRuleName -like "$FirewallRuleName" }

    }
    end {

    }
}
Function Add-BUSINESSAzSqlFirewallRule {
    <#
    .Synopsis
	    Whitelist IP address on production SQL server.

    .DESCRIPTION
        The Add-BUSINESSSQLFirewallRule function accepts a WAN IP address and is used for the purpose of whitelisting working from home sites.

    .EXAMPLE
        Add-BUSINESSSQLFirewallRule -IPAddress 'UserX'

	.NOTES
        You need to have the AzureADPreview module to use this function.
    #>
    [cmdletBinding()]
    param(
        [Parameter(HelpMessage = 'Enter Description')]
        [String]
        $FirewallRuleName,

        [Parameter(HelpMessage = 'Enter WAN IP')]
        [String]
        $IPAddress = (Invoke-WebRequest ifconfig.me/ip).Content.Trim(),

        [Parameter(HelpMessage = 'PROD or UAT?')]
        [ValidateSet("PROD", "UAT")]
        [String]
        $Env = "PROD"
    )

    BEGIN {
        $Var = @{
            ResourceGroupName = $Env.ToUpper() -eq "PROD" ? 'BUSINESSDBResources' : "rg-standard-uat"
            ServerName        = $Env.ToUpper() -eq "PROD" ? "BUSINESSit" : "sql-BUSINESS-uat"
            Env               = $Env.ToUpper() -eq "PROD" ? "DB" : "UAT"
        }
        Set-BUSINESSAzContext -Env $Var.Env

        $Day = (Get-Date).Day.ToString()
        $Month = (Get-Date).Month.ToString()
        if ($Day.length -eq 1) { $Day = "0$Day" }
        if ($Month.length -eq 1) { $Month = "0$Month" }

        if ($FirewallRuleName.Length -eq 0) {
            $FirewallRuleName = (Get-AzADUser -UserPrincipalName 'Joshua.VanDaalen@BUSINESS.com.au').DisplayName
        }
        $FirewallRuleName = "$FirewallRuleName - $Month$Day"
    }
    PROCESS {

        $AzSqlServerFirewallRuleParameters = @{
            'ResourceGroupName' = $Var.ResourceGroupName
            'ServerName'        = $Var.ServerName
            'FirewallRuleName'  = $FirewallRuleName
            'StartIpAddress'    = $IPAddress
            'EndIpAddress'      = $IPAddress
        }

        New-AzSqlServerFirewallRule @AzSqlServerFirewallRuleParameters
    }
    END { }
}

function Remove-BUSINESSAzSqlFirewallRule {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Enter Description')]
        [String]
        $FirewallRuleName,

        [Parameter(HelpMessage = 'PROD or UAT?')]
        [String]
        $Env = "PROD"
    )

    begin {
        $Var = @{
            ResourceGroupName = $Env.ToUpper() -eq "PROD" ? 'BUSINESSDBResources' : "rg-standard-uat"
            ServerName        = $Env.ToUpper() -eq "PROD" ? "BUSINESSit" : "sql-BUSINESS-uat"
            Env               = $Env.ToUpper() -eq "PROD" ? "DB" : "UAT"
        }
        Set-BUSINESSAzContext -Env $Var.Env
    }

    process {

        Get-AzSqlServerFirewallRule `
            -ResourceGroupName $Var.ResourceGroupName `
            -ServerName $Var.ServerName |
            Where-Object { $_.FirewallRuleName -like "$FirewallRuleName" } |
                Remove-AzSqlServerFirewallRule

    }
    end {

    }
}