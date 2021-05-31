#Requires –Modules Az
#Written by Joshua Van Daalen.
function New-BUSINESSAzResourceGroup {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$AzContextName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter()]
        [string]$Location = 'Australia Southeast',

        [Parameter()]
        [string]$Approver = '',

        [Parameter()]
        [string]$Environment = '',

        [Parameter()]
        [string]$Owner = '',

        [Parameter()]
        [string]$Requestor = ''
    )
    BEGIN { }
    PROCESS {

        Set-BUSINESSAzContext -Env $AzContextName
        
        $tags = @{
            Approver    = $Approver
            Environment = $Environment
            Owner       = $Owner
            Requestor   = $Requestor
        }

        New-AzResourceGroup `
            -Name $ResourceGroupName `
            -Location $Location `
            -Tag  $tags 
    }
    END { }
}
