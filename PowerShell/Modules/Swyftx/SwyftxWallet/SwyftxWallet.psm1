function Get-SwyftxWallet {
    [cmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false )][Long]$AssetId,
        [Parameter(Mandatory = $false )][switch]$ShowPrice = $false,
        [Parameter(Mandatory = $false )][switch]$ShowBuySell = $false
    )
    BEGIN {
        $wallet = Get-SwyftxAccountBalance
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

                $walletContents.Coin = $coin.Name
                $walletContents.Quantity = [math]::Round($availableBalance, 2)
                $walletContents.Value = $ShowPrice ? "{0:C0}" -f $coinValue : $coinValue

                if ($ShowBuySell -eq $true) {
                    
                    $walletContents.Buy = $coinPrice
                    $walletContents.Sell = $coin.Sell 
    
                }
                if ($coinValue -gt 1) {
                    [PSCustomObject]$walletContents
                }
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
            $accountBalance = Get-SwyftxHolding
            $walletContents = Get-SwyftxWallet
    
            foreach ($coin in $walletContents) {
                $total = $total + $coin.Value
                $coin.Value = "{0:C0}" -f $coin.Value
            }
            
            $profit = $total - $accountBalance
            $walletContents += 
            [PSCustomObject]@{
                'Coin'     = 'Cash'
                'Value'    = "{0:C0}" -f $profit
                'Quantity' = "{0:C0}" -f $total
            }

            Write-Output $walletContents 
        }
        Catch {
            throw $_
        }
    }
    END { }
}
