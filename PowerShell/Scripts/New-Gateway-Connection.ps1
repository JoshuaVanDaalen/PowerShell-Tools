#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Create a new connection
# New-AzVirtualNetworkGatewayConnection
Param (
    [Parameter(Mandatory)]
    [string]$RandomNumber,
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,
    [Parameter]
    [string]$Location = 'Australia Southeast'    
)
$connName = 'cn-aznet-to-vpn'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Get both gateways
$VirtualGateway = Get-AzVirtualNetworkGateway `
    -ErrorAction Stop `
    -ResourceGroupName $ResourceGroupName `
    -Name $vgwName
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LocalGateway = Get-AzLocalNetworkGateway `
    -ErrorAction Stop `
    -ResourceGroupName $ResourceGroupName `
    -Name $lgwName

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Create a connection between both gateways
New-AzVirtualNetworkGatewayConnection `
    -Name $connName `
    -ResourceGroupName $ResourceGroupName `
    -VirtualNetworkGateway1 $VirtualGateway `
    -LocalNetworkGateway2  $LocalGateway `
    -Location $Location `
    -ConnectionType IPsec `
    -SharedKey '#secretKEYbutn0tr3ally'