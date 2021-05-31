#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Create a new local network gateway
# New-AzLocalNetworkGateway
Param (
    [Parameter(Mandatory)]
    [string]$RandomNumber,
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory)]        
    [string]$Location = 'Australia Southeast'    
)

$lgwName = "lgw-devops-vpn-$RandomNumber"
$lgwPrefix50 = "111.222.333.0/24"
$lgwIP5 = "123.123.123.123" # local networks public IP, i think
# Optional
$BGPPeerIP5 = "111.222.333.0" # local network internal address, i think, it was a long time ago i wrote this
$lgwASN5 = 65050

New-AzLocalNetworkGateway `
    -Name $lgwName `
    -ResourceGroupName $RG `
    -Location $Location `
    -GatewayIpAddress $lgwIP5 `
    -AddressPrefix $lgwPrefix50 `
    # -BgpPeeringAddress $BGPPeerIP5 `# Not needed in most configs
    # -Asn $lgwASN5 
