# Writtern By: Joshua Van Daalen
# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ##########################################################################################
# #
$P2SRootCertName = "aznetRemoteGateway-Mac-Root"
$P2SChildCertName = "aznetRemoteGateway-Mac-Child"
$rootCertFilePath = "S:\aznet\$P2SRootCertName"
$childCertFilePath = "S:\aznet\$P2SChildCertName"
$certPassword = ConvertTo-SecureString -String "bigpassword!" -Force –AsPlainText
$CertStoreLocation = 'Cert:\CurrentUser\My'
# ##########################################################################################
#
$rootCert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=$P2SRootCertName" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation $CertStoreLocation -KeyUsageProperty Sign -KeyUsage CertSign

Export-PfxCertificate `
    -Cert $rootcert.PSPath `
    -FilePath "$rootCertFilePath.pfx" `
    -Password $certPassword

Export-Certificate `
    -Cert $rootcert.PSPath `
    -FilePath "$rootCertFilePath.cer" `

##########################################################################################
#
$childCert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject "CN=$P2SChildCertName" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation $CertStoreLocation `
    -Signer $rootCert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
    -DnsName P2SChildCert  

Export-PfxCertificate `
    -Cert $childCert.PSPath `
    -FilePath "$childCertFilePath.pfx" `
    -Password $certPassword

Export-Certificate `
    -Cert $childCert.PSPath `
    -FilePath "$childCertFilePath.cer" `

$certB64 = new-object System.Security.Cryptography.X509Certificates.X509Certificate2("$rootCertFilePath.cer")
$CertBase64 = [system.convert]::ToBase64String($certB64.RawData)
$P2SRootCertName | clip
$CertBase64 | clip

# Upload into Azure
Add-AzVpnClientRootCertificate `
    -VpnClientRootCertificateName $P2SRootCertName `
    -VirtualNetworkGatewayname 'aznetRemoteGateway' `
    -ResourceGroupName 'aznetResources' `
    -PublicCertData $CertBase64


    