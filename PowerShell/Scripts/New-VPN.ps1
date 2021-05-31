#Requires –Modules Az

# vnet-to-sql-prod
# Region
# Australia Southeast
# IP addresses
# Address space
# 10.10.200.0/29,10.10.10.0/24
# Subnet
# snet-to-sql-prod (10.10.10.0/24)

#New version
$Location = 'Australia Southeast'  
$ResourceGroupName = "rg-public-uat"

$publicIpName = "pip-sql-vpn-prod"
$GWSubPrefix = "10.100.200.0/24";
$GWSubName = "GatewaySubnet"
$VNetName = "vnet-to-sql-uat"
$vgwName = "vgw-sql-vpn-prod"

$vnet = Get-AzVirtualNetwork `
  -Name $VNetName `
  -ResourceGroupName $ResourceGroupName

$pip = New-AzPublicIpAddress `
  -Name $publicIpName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -AllocationMethod Dynamic

$gwSubnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name $GWSubName `
  -AddressPrefix $GWSubPrefix

$subnet = Add-AzVirtualNetworkSubnetConfig `
  -Name "GatewaySubnet" `
  -VirtualNetwork $vnet
-AddressPrefix $GWSubPrefix

$subnet = Get-AzVirtualNetworkSubnetConfig `
  -Name "GatewaySubnet" `
  -VirtualNetwork $vnet 

$ipconf = New-AzVirtualNetworkGatewayIpConfig `
  -Name "gwipconf" `
  -Subnet $subnet `
  -PublicIpAddress $pip

$vnet | Set-AzVirtualNetwork
  
New-AzVirtualNetworkGateway `
  -ErrorAction Stop `
  -Name $vgwName `
  -ResourceGroupName $ResourceGroupName `
  -Location $Location `
  -IpConfigurations $ipconf `
  -GatewayType Vpn `
  -VpnType RouteBased `
  -EnableBgp $false `
  -GatewaySku 'VpnGw1' `
  -VpnClientProtocol "IKEv2"

# Done





































# Start Initial variables 

# End Initial variables 

# $NetworkName = "vnet-devops-southeastau-164"
# $NicName = "nic-devops-southeastau-$randomNumber"
# $subnetName = "snet-devops-southeastau-$randomNumber"
# $vgwName = "vgw-devops-internal-164"
# $publicIpName = "pip-devops-vgw-164"
# $vgwSKU = 'Basic'



try {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Set subscription context to testing subscription
  $devopstest001 = 'b4c8eb78-733b-4b60-bc51-a0d4bba7e7cc'
  #PROD# #PROD #PROD#
  # # $devopstest001 = 'e4e458b8-5034-4d35-a73d-7d8689767fba' #PROD# #PROD#
  #PROD# #PROD# #PROD#
    
  $Location = 'Australia Southeast'
  ##########################################################################################
  #
  Set-AzContext `
    -ErrorAction Stop `
    -SubscriptionId $devopstest001 
        
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ##########################################################################################
  # Creating Vpn groups for Azure AD auth on Vpn database
  $randomNumber = (Get-Random).tostring().substring(0, 3)

  $ADGroupOwner = Get-AzADUser `
    -UserPrincipalName 'josh@tallyit.com.au' `
    -ErrorAction Stop 

  $VpnUserGroupMember = Get-AzADUser `
    -UserPrincipalName 'josh-test@tallyit.com.au' `
    -ErrorAction Stop


  $VpnAdminGroupName = "vpn-admin-devops-test-$randomNumber"
  $VpnUserGroupName = "vpn-user-devops-test-$randomNumber"
  ##########################################################################################
  # VPN Admin
  New-AzADGroup `
    -ErrorAction Stop `
    -DisplayName $VpnAdminGroupName `
    -MailNickName $VpnAdminGroupName

  # VPN User
  New-AzADGroup `
    -ErrorAction Stop `
    -DisplayName $VpnUserGroupName `
    -MailNickName $VpnUserGroupName

  ##########################################################################################
  # Add group owner
  $VpnAdminGroup = Get-AzADGroup `
    -ErrorAction Stop `
    -SearchString $VpnAdminGroupName `
        
  $VpnUserGroup = Get-AzADGroup `
    -ErrorAction Stop `
    -SearchString $VpnUserGroupName 

  # ##########################################################################################
  # Add group members
  Add-AzADGroupMember `
    -ErrorAction SilentlyContinue `
    -MemberObjectId $ADGroupOwner.Id `
    -TargetGroupObjectId $VpnAdminGroup.Id 

  Add-AzADGroupMember `
    -ErrorAction SilentlyContinue `
    -MemberObjectId $VpnUserGroupMember.Id `
    -TargetGroupObjectId $VpnUserGroup.Id 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Create resource group
  $ResourceGroupName = "rg-devops-test-$randomNumber"
  $ResourceGroupName = "rg-tally-vpn-devops"
  ##########################################################################################
  #
  New-AzResourceGroup `
    -ErrorAction Stop `
    -Name $ResourceGroupName `
    -Location $Location `
    -Tag @{Approver = 'Ewen Stewart'; `
      Environment   = "DevOps"; `
      Owner         = 'Joshua Van Daalen'; `
      Requestor     = 'Joshua Van Daalen';
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ##########################################################################################
  # Set Variables 
  $snetNumb = $randomNumber.Substring(0, 2)
  $RG = $ResourceGroupName
  # $VNetName = "vnet-devops-vpn-$randomNumber"
  # $VNetPrefix1 = "192.168.0.0/16"
  # $VNetPrefix2 = "10.254.0.0/16"

  # $VNetPrefix2 = "10.254.$snetNumb.0/24"
  $VNetPrefix1 = "10.0.$snetNumb.0/24"; $VNetName = "vnet-devops-vpn-$randomNumber"
  $FESubPrefix = "10.0.$snetNumb.0/26"; $FESubName = "snet-devops-external-$randomNumber"
  $GWSubPrefix = "10.0.$snetNumb.64/26"; $GWSubName = "GatewaySubnet" # Can't change this name

  $publicIpName = "pip-devops-vpn-$randomNumber"
  $GWIPconfName = "gwipconf"

  # $FESubPrefix = "192.168.1.0/24"

  # $BESubName = "snet-devops-internal-$randomNumber"
  # $BESubPrefix = "10.254.1.0/24"

  # $GWSubName = "GatewaySubnet" # Can't change this name
  # $GWSubPrefix = "192.168.200.0/26"

  # $VPNClientAddressPool = "172.17.201.0/24"
  $VPNClientAddressPool = "192.168.220.0/24"

  $vgwName = "vgw-devops-vpn-$randomNumber"

  ##########################################################################################
  # Configure a VNet

  $fesub = New-AzVirtualNetworkSubnetConfig `
    -ErrorAction Stop `
    -WarningAction SilentlyContinue `
    -Name $FESubName `
    -AddressPrefix $FESubPrefix 
  # $besub = New-AzVirtualNetworkSubnetConfig `
  #   -ErrorAction Stop `
  #   -WarningAction SilentlyContinue `
  #   -Name $BESubName `
  #   -AddressPrefix $BESubPrefix
  $gwsub = New-AzVirtualNetworkSubnetConfig `
    -ErrorAction Stop `
    -WarningAction SilentlyContinue `
    -Name $GWSubName `
    -AddressPrefix $GWSubPrefix

  ##########################################################################################
  #1. Create a virtual network
  New-AzVirtualNetwork `
    -ErrorAction Stop `
    -Name $VNetName `
    -ResourceGroupName $RG `
    -Location $Location `
    -DnsServer 10.2.1.3 `
    -Subnet $fesub, $gwsub `
    -AddressPrefix $VNetPrefix1
  # -AddressPrefix $VNetPrefix1, $VNetPrefix2 `
  # -Subnet $fesub, $besub, $gwsub `
  ##########################################################################################
  #
  $vnet = Get-AzVirtualNetwork `
    -ErrorAction Stop `
    -Name $VNetName `
    -ResourceGroupName $RG
  $subnet = Get-AzVirtualNetworkSubnetConfig `
    -Name "GatewaySubnet" `
    -VirtualNetwork $vnet

  ##########################################################################################
  #
  $pip = New-AzPublicIpAddress `
    -ErrorAction Stop `
    -Name $publicIpName `
    -ResourceGroupName $RG `
    -Location $Location `
    -AllocationMethod Dynamic
  $ipconf = New-AzVirtualNetworkGatewayIpConfig `
    -Name $GWIPconfName `
    -Subnet $subnet `
    -PublicIpAddress $pip

  # #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ##########################################################################################
  # # Create the VPN gateway
  New-AzVirtualNetworkGateway `
    -ErrorAction Stop `
    -Name $vgwName `
    -ResourceGroupName $RG `
    -Location $Location `
    -IpConfigurations $ipconf `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -EnableBgp $false `
    -GatewaySku 'VpnGw1' `
    -VpnClientProtocol "IKEv2"

  # ##########################################################################################
  # #
  $Gateway = Get-AzVirtualNetworkGateway `
    -ErrorAction Stop `
    -ResourceGroupName $RG `
    -Name $vgwName 
  Set-AzVirtualNetworkGateway `
    -ErrorAction Stop `
    -VirtualNetworkGateway $Gateway `
    -VpnClientAddressPool $VPNClientAddressPool

  #Make CERT
}
CATCH {
  write-host -ForegroundColor Red $_.Exception.Message
  write-host -ForegroundColor Red $_.Exception.ItemName
}


# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##########################################################################################
# #
$P2SRootCertName = "P2SRootCert"
$filePathForCert = "C:\cert\P2SRootCert"

# ##########################################################################################
#
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
  -Subject "CN=$P2SRootCertName" -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

##########################################################################################
#
New-SelfSignedCertificate -Type Custom -KeySpec Signature `
  -Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
  -DnsName P2SChildCert  


##########################################################################################
#
$cert = Get-ChildItem -Path cert:\CurrentUser\My\ | ? { $_.Subject -like "*P2S*Cert*" }
# new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)

$CertBase64 = [system.convert]::ToBase64String($cert.RawData)
$p2srootcert = New-AzVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $CertBase64

Add-AzVpnClientRootCertificate `
  -VpnClientRootCertificateName "$P2SRootCertName.cer" `
  -VirtualNetworkGatewayname $vgwName `
  -ResourceGroupName $RG `
  -PublicCertData $CertBase64

##########################################################################################
# # #
# Add-AzVpnClientRootCertificate `
#     -VpnClientRootCertificateName $P2SRootCertName `
#     -VirtualNetworkGatewayname 'AemoRemoteGateway' `
#     -ResourceGroupName 'AemoMarketNetResources' `
#     -PublicCertData $p2srootcert

# ##########################################################################################
# #

# ##########################################################################################
# #


# $SubnetConfigName = "GatewaySubnet"
# $AddressRange = '10.0.0.0/16'
# $SubnetRange = '10.0.0.0/24'

# $SubnetConfig = New-AzVirtualNetworkSubnetConfig `
#     -Name $SubnetConfigName `
#     -AddressPrefix $SubnetRange

# New-AzVirtualNetwork `
#     -Name 'TestPeering' `
#     -ResourceGroupName $RG `
#     -Location $Location `
#     -AddressPrefix $AddressRange `
#     -Subnet $SubnetConfig `
#     -DnsServer 10.2.1.3



# ##########################################################################################
# # New SQL server and database
# $ServerName = "sql-devops-test-$randomNumber"
# $DatabaseName = "sqldb-devops-test-$randomNumber"
# $strPass = ConvertTo-SecureString -String "sudoAZSQL2020" -AsPlainText -Force
# $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('TallySuper', $strPass)

# ##########################################################################################
# # 



# $Gateway = Get-AzVirtualNetworkGateway `
#     -ResourceGroupName "AemoMarketNetResources" `
#     -Name "AemoRemoteGateway"
# Set-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway `
#     -AadTenantUri "https://login.microsoftonline.com/928ba9de-43c7-4df4-a93a-0a215c5322dc" `
#     -AadIssuerUri "https://sts.windows.net/928ba9de-43c7-4df4-a93a-0a215c5322dc/" `
#     -AadAudienceId "a21fce82-76af-45e6-8583-a08cb3b956f9"

# "aadTenantUri": "https://login.microsoftonline.com/928ba9de-43c7-4df4-a93a-0a215c5322dc\",
# "aadAudienceId": "a21fce82-76af-45e6-8583-a08cb3b956g9\",
# "aadIssuerUri": "https://sts.windows.net/928ba9de-43c7-4df4-a93a-0a215c5322dc/\"
						 
# Set-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway -VpnClientRootCertificates $rootCert -RemoveAadAuthentication
# $gw = Get-AzVirtualNetworkGateway -Name <name of VPN gateway> -ResourceGroupName <Resource group>
# Set-AzVirtualNetworkGateway -VirtualNetworkGateway $gw -VpnClientRootCertificates @()
# Set-AzVirtualNetworkGateway -VpnClientAddressPool 192.168.0.0/24 -VpnClientProtocol OpenVPN








# [1:06 PM] PS >$RG1 = 'AemoMarketNetResources'
# [1:06 PM] PS >$GWName1 = 'AemoRemoteGateway'
# [1:06 PM] PS >$vnet1gw = Get-AzVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
# [1:06 PM] PS >
# [1:06 PM] PS >
# [1:06 PM] PS >$vnet1gw.Id


# $vnet5gw = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway
# $vnet5gwName = 'vgw-devops-vpn-100'
# $vnet5gw.Name = $vnet5gwName
# $vnet5gwId = '/subscriptions/b4c8eb78-733b-4b60-bc51-a0d4bba7e7cc/resourceGroups/rg-devops-test-100/providers/Microsoft.Network/virtualNetworkGateways/vgw-devops-vpn-100'
# $vnet5gw.Id = $vnet5gwId
# $Connection15 = "VNet1toVNet5"
# New-AzVirtualNetworkGatewayConnection -Name $Connection15 -ResourceGroupName $RG1 -VirtualNetworkGateway1 $vnet1gw -VirtualNetworkGateway2 $vnet5gw -Location $Location1 -ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'


# [1:07 PM] PS >$RG5 = 'rg-devops-test-100'
# [1:07 PM] PS >$GWName5 = 'vgw-devops-vpn-100'
# [1:08 PM] PS >$vnet5gw = Get-AzVirtualNetworkGateway -Name $GWName5 -ResourceGroupName $RG5
# [1:08 PM] PS >
# [1:08 PM] PS >
# [1:08 PM] PS >
# $vnet1gw = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway
# $vnet1gwName = 'AemoRemoteGateway'
# $vnet1gw.Name = $vnet1gwName
# $vnet1gwId = '/subscriptions/e4e458b8-5034-4d35-a73d-7d8689767fba/resourceGroups/AemoMarketNetResources/providers/Microsoft.Network/virtualNetworkGateways/AemoRemoteGateway'
# $vnet1gw.Id = $vnet1gwId

# $Connection51 = "VNet5toVNet1"
# New-AzVirtualNetworkGatewayConnection -Name $Connection51 -ResourceGroupName $RG5 -VirtualNetworkGateway1 $vnet5gw -VirtualNetworkGateway2 $vnet1gw -Location $Location5 -ConnectionType Vnet2Vnet -SharedKey 'AzureA1b2C3'





# # $devopstest001 = 'e4e458b8-5034-4d35-a73d-7d8689767fba' #PROD# #PROD#




$Location1 = 'Australia Southeast'
$Location5 = 'Australia Southeast'
#Set subscription

#PROD# #PROD# #PROD#
$devopstest001 = 'e4e458b8-5034-4d35-a73d-7d8689767fba'#PROD# #PROD#
#PROD# #PROD# #PROD#
Set-AzContext `
  -ErrorAction Stop `
  -SubscriptionId $devopstest001 

$RG1 = 'AemoMarketNetResources'
$GWName1 = 'AemoRemoteGateway'
$vnet1gw = Get-AzVirtualNetworkGateway `
  -Name $GWName1 `
  -ResourceGroupName $RG1
$vnet1gwName = $vnet1gw.Name
$vnet1gwId = $vnet1gw.Id
$Connection15 = "AEMOtoVNet840"

#Set subscription
$devopstest001 = 'b4c8eb78-733b-4b60-bc51-a0d4bba7e7cc'
Set-AzContext `
  -ErrorAction Stop `
  -SubscriptionId $devopstest001 

$RG5 = 'rg-devops-test-840'
$GWName5 = 'vgw-devops-vpn-840'
$vnet5gw = Get-AzVirtualNetworkGateway `
  -Name $GWName5 `
  -ResourceGroupName $RG5
$vnet5gwName = $vnet5gw.Name
$vnet5gwId = $vnet5gw.Id
$Connection51 = "VNet840toAEMO"


#Set subscription
#PROD# #PROD# #PROD#
$devopstest001 = 'e4e458b8-5034-4d35-a73d-7d8689767fba'#PROD# #PROD#
#PROD# #PROD# #PROD#
Set-AzContext `
  -ErrorAction Stop `
  -SubscriptionId $devopstest001 

New-AzVirtualNetworkGatewayConnection `
  -Name $Connection15 `
  -ResourceGroupName $RG1 `
  -VirtualNetworkGateway1 $vnet1gw `
  -VirtualNetworkGateway2 $vnet5gw `
  -Location $Location1 `
  -ConnectionType Vnet2Vnet `
  -SharedKey '@kindaCustombutnotr3lly' `
  -EnableBgp $True

#Set subscription
$devopstest001 = 'b4c8eb78-733b-4b60-bc51-a0d4bba7e7cc'
Set-AzContext `
  -ErrorAction Stop `
  -SubscriptionId $devopstest001 
    
New-AzVirtualNetworkGatewayConnection `
  -Name $Connection51 `
  -ResourceGroupName $RG5 `
  -VirtualNetworkGateway1 $vnet5gw `
  -VirtualNetworkGateway2 $vnet1gw `
  -Location $Location5 `
  -ConnectionType Vnet2Vnet `
  -SharedKey '@kindaCustombutnotr3lly' `
  -EnableBgp $True




$RG = "rg-devops-test-171"
$lgwName = "lgw-devops-vpn-$randomNumber"
$connName = 'cn-marketnew-to-vpn'
$lgwPrefix50 = "146.178.211.0/24"
$lgwIP5 = "202.44.78.10"
$lgwASN5 = 65050
$BGPPeerIP5 = "146.178.211.0"

New-AzLocalNetworkGateway `
  -Name $lgwName `
  -ResourceGroupName $RG `
  -Location $Location `
  -GatewayIpAddress $lgwIP5 `
  -AddressPrefix $lgwPrefix50 `
  -Asn $lgwASN5 `
  -BgpPeeringAddress $BGPPeerIP5


$VirtualGateway = Get-AzVirtualNetworkGateway `
  -ErrorAction Stop `
  -ResourceGroupName $RG `
  -Name $vgwName

$LocalGateway = Get-AzLocalNetworkGatewa    y `
  -ErrorAction Stop `
  -ResourceGroupName $RG `
  -Name $lgwName

New-AzVirtualNetworkGatewayConnection `
  -Name $connName `
  -ResourceGroupName $RG `
  -VirtualNetworkGateway1 $VirtualGateway `
  -LocalNetworkGateway2  $LocalGateway `
  -Location $Location `
  -ConnectionType IPsec `
  -SharedKey '#secretKEYbutn0tr3ally'

