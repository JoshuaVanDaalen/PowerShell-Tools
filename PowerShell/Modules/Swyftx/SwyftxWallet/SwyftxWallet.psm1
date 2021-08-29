function Get-SwyftxWallet {
    [cmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false )][Long]$AssetId,
        [Parameter(Mandatory = $false )][switch]$ShowPrice = $false,
        [Parameter(Mandatory = $false )][switch]$ShowBuySell = $false
    )
    BEGIN {
        $wallet = Get-SwyftxAccountBalance | Where-Object { $_.availableBalance -gt 1 }
    }
    PROCESS {
        Try {
            if ($AssetId) {

                $walletContents = [ordered]@{ }

                $walletValues = $wallet | Where-Object { $_.assetId -eq $AssetId }
                    
                $coin = Get-SwyftxAssetInfo -AssetId $AssetId
                
                [float]$availableBalance = $walletValues.availableBalance
                [float]$coinPrice = $coin.Sell
                $coinValue = ($availableBalance * $coinPrice)

                $mAvailableBalance = [math]::Round($availableBalance, 2)

                $walletContents.Coin = $coin.Name
                $walletContents.Quantity = $ShowPrice ? [math]::Round($availableBalance, 2) : "{0:N0}" -f $mAvailableBalance 
                $walletContents.Value = $ShowPrice ? "{0:C0}" -f $coinValue : $coinValue

                if ($ShowBuySell -eq $true) {
                    
                    $walletContents.Buy = $coinPrice
                    $walletContents.Sell = $coin.Sell 
    
                }
                [PSCustomObject]$walletContents
            }
            else {
                foreach ($a in $wallet) {
                    if ($a.assetId -ne 1 -and $a.assetId -ne 36  ) {

                        $params = @{
                            AssetId     = $a.assetId
                            ShowPrice   = $ShowPrice.IsPresent
                            ShowBuySell = $ShowBuySell.IsPresent
                        }

                        Get-SwyftxWallet @params

                    }
                }
            }
        }
        Catch {
            throw $_
        }
    }
    END { }
}

function Show-SwyftxWallet {
    [cmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false )][Bool]$ShowCoin = $false
    )
    BEGIN { }
    PROCESS {
        Try {

            $total = 0
            # $accountBalance = Get-SwyftxHolding
            $accountBalance = 0
            $walletContents = Get-SwyftxWallet
    
            foreach ($coin in $walletContents) {
                $total = $total + $coin.Value
                $coin.Value = "{0:C0}" -f $coin.Value
            }
            
            $profit = $total - $accountBalance
            if ($walletContents.count -lt 2) {
                $shiba = Get-SwyftxAssetInfo 293
                $inFor = 19520.988777
                $loss = $profit - $inFor 
                
                $walletContents = 
                [PSCustomObject]@{
                    'Coin'     = $walletContents.Coin
                    'Value'    = "{0:C0}" -f $profit
                    'Cash'     = "{0:C0}" -f $loss
                    'Quantity' = $walletContents.Quantity
                    'Buy'      = $shiba.Buy
                    'Sell'     = $shiba.Sell
                    'Time'     = (Get-Date -Format "HH:mm:ss")
                }
            }
            elseif ($walletContents.count -gt 1) {
                $walletContents += 
                [PSCustomObject]@{
                    'Coin'     = 'Cash'
                    'Value'    = "{0:C0}" -f $profit
                    'Quantity' = "{0:C0}" -f $total
                }
            }

            Write-Output $walletContents 
        }
        Catch {
            throw $_
        }
    }
    END { }
}
