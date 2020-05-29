
Function Add-BUSINESSSQLFirewallRule {
    <#
        .SYNOPSIS
	    Whitelist IP address on SQL server.

        .DESCRIPTION
        The Add-BUSINESSSQLFirewallRule function accepts a WAN IP address and is used for the purpose of whitelisting working from home sites.

        .PARAMETER FirewallRuleName
        Specifies name for the rule which is unique in your Azure AD tenant.

        .PARAMETER IPAddress
        Specifies the public IP address to whitelist.

        .EXAMPLE
        Add-BUSINESSSQLFirewallRule -FirewallRuleName 'Josh - 20200529' -IPAddress '52.95.132.125'

        .EXAMPLE
        Add-BUSINESSSQLFirewallRule 'Josh - 20200529' '52.95.132.125'

        .EXAMPLE
        Add-BUSINESSSQLFirewallRule 'Josh - 20200529' '52.95.132.125' -AzContextName 'PROD'

        .LINK
        Online version: https://github.com/greenSacrifice/WindowsPowerShell
    #>

    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $True,
            HelpMessage = 'Enter Description')] 
        [String]
        $FirewallRuleName,
        
        [Parameter(Mandatory = $True,
            HelpMessage = 'Enter WAN IP')] 
        [String]
        $IPAddress,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Enter Azure subscrption name')] 
        [String]
        $AzContextName = 'PROD'
    )

    BEGIN {
        # Logging...        
    }
    PROCESS {
        
        $Var = @{            
            AzContextName     = $AzContextName.ToUpper() -eq 'PROD' ? 'Production Subscription' : 'UAT Subscription'
            ResourceGroupName = $AzContextName.ToUpper() -eq 'PROD' ? 'rg-source-prod-vic' : 'rg-source-uat-vic'
            ServerName        = $AzContextName.ToUpper() -eq 'PROD' ? 'sql-source-prod' : 'sql-source-prod'
        }
        Get-AzContext -ListAvailable | Where-Object { $_.Subscription.Name -match $AzContextName } | Set-AzContext | Out-Null

        $AzSqlServerFirewallRuleParameters = @{
            'ResourceGroupName' = $Var.ResourceGroupName
            'ServerName'        = $Var.ServerName
            'FirewallRuleName'  = $FirewallRuleName
            'StartIpAddress'    = $IPAddress
            'EndIpAddress'      = $IPAddress
        }

        New-AzSqlServerFirewallRule @AzSqlServerFirewallRuleParameters
    }
    END {
        # if ($ErrorsHappened) {
        #     Write-verbose "Error has been logged to $FullLogPath."
        # }
    }
}
