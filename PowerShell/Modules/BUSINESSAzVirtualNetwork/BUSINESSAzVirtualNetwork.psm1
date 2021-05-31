#Requires –Modules Az
#Written by Joshua Van Daalen.
function New-BUSINESSAzVirtualNetwork {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter()]        
        [string]$Location = 'Australia Southeast',

        [Parameter(Mandatory)]
        [string]$VirtualNetworkName,

        [Parameter(Mandatory)]
        [string]$AddressPrefix = '10.0.0.0/16',

        [Parameter(Mandatory)]
        [string]$SubnetName,
        
        [Parameter()]
        [string]$SubnetAddressPrefix = '10.0.0.0/24'
    )
    BEGIN { }
    PROCESS {

        New-AzVirtualNetwork `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -Name $VirtualNetworkName `
            -AddressPrefix $AddressPrefix `
            -Subnet (New-AzVirtualNetworkSubnetConfig `
                -Name $SubnetName `
                -AddressPrefix $SubnetAddressPrefix)
    }
    END {}
}
