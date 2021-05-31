# Licensed under the MIT license.
# Copyright (C) 2017 Kristofer Liljeblad

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, 
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Get-AzureUsageCost

# The following script returns the Azure Usage from a specific Subscription ID, collects a Rate Card and applies the correct cost
# to the specified resource. The script uses the latest reported price and only the first tier of any resources with tiered pricing.
# For authentication this script uses an Azure AD Application with associated tenant id, client id and client password. Before running
# this script, make sure you create such an Azure AD Application and assigns the appropriate permission to it.

# Replace the following configuration settings

$tenantId = 'a47bd588-f2c9-4146-b0b2-d39f56758e0e' 
$clientId = '98ff930e-xxxx-490e-XXXX-49c9b2779185'
$clientPassword = 'x3rkTXXXXQrA5QgjXXXXXXX7ozEGeahsnZAN1Abra4='
$subscriptionId = '3a856395-1af1-XXXX-925d-XXXX57e5995'

# Rate Card Settings
$offerDurableId = 'MS-AZR-0003p' #Pay-As-You-Go
$currency = 'AUS' # "SEK"
$locale = 'en-AU' # "sv-SE"
$regionInfo = 'AU' # "SE"

# Usage Settings
$startTime = '2017-08-01'
$endTime = '2017-11-19'
$outFile = "c:\tmp\usage $startTime $endTime.csv"


# *** Login ****

$loginUri = "https://login.microsoftonline.com/$tenantId/oauth2/token?api-version=1.0"

$body = @{
    grant_type    = 'client_credentials'
    resource      = 'https://management.core.windows.net/'
    client_id     = $clientId
    client_secret = $clientPassword
}

Write-Host 'Authenticating' 

$loginResponse = Invoke-RestMethod $loginUri -Method Post -Body $body
$authorization = $loginResponse.token_type + ' ' + $loginResponse.access_token

# Use the same header in all the calls, so save authorization in a header dictionary

$headers = @{
    authorization = $authorization
}

# *** Rate Card ***

$rateCardFilter = "OfferDurableId eq '$offerDurableId' and Currency eq '$currency' and Locale eq '$locale' and RegionInfo eq '$regionInfo'"
$rateCardUri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Commerce/RateCard?api-version=2016-08-31-preview&`$filter=$rateCardFilter"

Write-Host 'Querying Rate Card API'

$rateCardResponse = Invoke-RestMethod $rateCardUri -Headers $headers -ContentType 'application/json'

$rateCard = @{}

foreach ($meter in $rateCardResponse.Meters) {
    # Note, the following if statement can be written more compact, but due to readability, I've kept it this way

    if ($rateCard[$meter.MeterId]) {
        # A previous price was found

        if ($meter.EffectiveDate -gt $rateCard[$meter.MeterId].EffectiveDate) {
            # Found updated price for $meter.MeterId

            $rateCard[$meter.MeterId] = $meter
        }
    }
    else {
        # First time a price was found for $meter.MeterId

        $rateCard[$meter.MeterId] = $meter
    }
}


# *** Usage ***

$usageUri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Commerce/UsageAggregates?api-version=2015-06-01-preview&reportedStartTime=$startTime&reportedEndTime=$endTime&aggregationGranularity=Daily&showDetails=false"
$usageRows = New-Object System.Collections.ArrayList

Write-Host 'Querying Azure Usage API'

do {
    Write-Host '.'

    $usageResult = Invoke-RestMethod $usageUri -Headers $headers -ContentType 'application/json'

    foreach ($usageRow in $usageResult.value) {
        $usageRows.Add($usageRow) > $null
    }

    $usageUri = $usageResult.nextLink

    # If there's a continuation, then call API again
} while ($usageUri)

Write-Host 'Organizing Data'

foreach ($item in $usageRows) {
    # Fix "bug" in Usage API that return instanceData as a string instead of as JSON
    if ($item.properties.instanceData) {
        $item.properties.instanceData = ConvertFrom-Json $item.properties.instanceData
    }
}

$data = $usageRows | Select-Object -ExpandProperty properties

foreach ($item in $data) {
    # Fix members to make them easier to consume

    $usageStartDate = (Get-Date $item.usageStartTime).ToShortDateString()
    $usageEndDate = (Get-Date $item.usageEndTime).ToShortDateString()

    $item | Add-Member 'usageStartDate' $usageStartDate
    $item | Add-Member 'usageEndDate' $usageEndDate

    $item | Add-Member 'location' $item.instanceData.'Microsoft.Resources'.location
    $item | Add-Member 'resourceUri' $item.instanceData.'Microsoft.Resources'.resourceUri
    $item | Add-Member 'additionalInfo' $item.instanceData.'Microsoft.Resources'.additionalInfo
    $item | Add-Member 'tags' $item.instanceData.'Microsoft.Resources'.tags

    $item.resourceUri -match '(?<=resourceGroups\/)(?<resourceGroup>.*)(?=\/providers)' | Out-Null
    $item | Add-Member 'resourceGroup' $Matches.resourceGroup

    # Lookup pricing

    $meterRate0 = $rateCard[$item.meterId].MeterRates.0
    $total = $item.quantity * $MeterRate0

    $item | Add-Member 'meterRate0' $meterRate0 # Use the first MeterRate and ignored tiered pricing for this calculation
    $item | Add-Member 'total' $total
    $item | Add-Member 'currency' $currency
}

# *** Fine tune result and only keep interesting information ***

$reportResult = $data | Select-Object usageStartDate, usageEndDate, location, meterName, meterCategory, meterSubCategory, quantity, unit, meterRate0, total, currency, resourceGroup, meterId, resourceUri, additionalInfo, tags

# *** Export to File ***

Write-Host "Exporting to $outFile"

$reportResult | Export-Csv $outFile -UseCulture -NoTypeInformation