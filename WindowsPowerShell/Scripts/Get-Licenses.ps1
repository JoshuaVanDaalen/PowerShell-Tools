

Connect-MsolService


$licenses = Get-MsolAccountSku | Where-Object { $_.AccountSkuId -like "*O365_BUSINESS_PREMIUM" -or  $_.AccountSkuId -like "*AAD_PREMIUM" }

$aAD_premium = $licenses.Where({$_.AccountSkuId -like "*AAD_PREMIUM" })
$o365BusinessPremium = $licenses.Where({$_.AccountSkuId -like "*O365_BUSINESS_PREMIUM" })


if($aAD_premium.ActiveUnits -le $aAD_premium.ConsumedUnits)
{
    Write-Host -ForegroundColor 'Yellow' 'Order more ADP1 licenses rhipe'
}

if($o365BusinessPremium.ActiveUnits -le $o365BusinessPremium.ConsumedUnits)
{
    Write-Host -ForegroundColor 'Yellow' 'Order more Business Premium licenses from rhipe'
}

Get-MsolUser | Where-Object { ($_.licenses).AccountSkuId -like "*O365_BUSINESS_PREMIUM" }

$usersLicenses = `
    Get-MsolUser |
Where-Object { ($_.licenses).AccountSkuId -like "*O365_BUSINESS_PREMIUM" }

$usersLicenses.Where( { $_.UserPrincipalName -like '*some.person@domain.com.au*' })




