
function Set-BUSINESSContext {
    <#
        .SYNOPSIS
	    Change Azure subscriptions using pre-set subscription names.

        .DESCRIPTION
        The Add-BUSINESSContext function accepts a WAN IP address and is used for the purpose of whitelisting working from home sites.

        .PARAMETER Env
        This is the display name of the subscription found in your Azure tenant        

        .EXAMPLE
        Add-BUSINESSContext -Env 'PROD'

        .EXAMPLE
        Add-BUSINESSContext 'PROD'

        .LINK
        Online version: https://github.com/greenSacrifice/WindowsPowerShell
    #>
    [cmdletBinding()]
    Param (
        [Parameter()]
        [string]$Env = "DEVOPS"
    )
    BEGIN { }
    PROCESS {
        switch ($Env.ToUpper()) {
            "DEVOPS" { $SubscriptionID = '52aaec5b-54e8-4a7d-bf92-15d3af1c7b7a' }
            "UAT" { $SubscriptionID = '49830799-c168-424d-88e5-85fbbabde537' }
            "PROD" { $SubscriptionID = '4c750b9f-bc73-40a6-ae62-6ca1426a2400' }
            Default { $SubscriptionID = $Null }
        }

        if ($SubscriptionID -eq $Null) { }
        else {
            Set-AzContext -ErrorAction Stop -SubscriptionId $SubscriptionID 
        }
    }
    END { }
}
