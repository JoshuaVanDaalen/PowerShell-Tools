function Get-SwyftxMeme {
    [cmdletBinding()]
    Param ( )
    BEGIN {

        $memeOrder = @{
            'orderUuid'       = 'ord_BemmgiWPYtKjSBFFhkJWoo'
            'order_type'      = '1'
            'primary_asset'   = '36'
            'secondary_asset' = '293'
            'quantity_asset'  = '36'
            'quantity'        = '900.12848979751'
            'trigger'         = '8.821859124732E-06'
            'status'          = '4'
            'created_time'    = '1625095417331'
            'updated_time'    = '1625095419748'
            'amount'          = 101412927.096342
            'total'           = '900.12848979751'
            'rate'            = '8.82262E-06'
            'audValue'        = 1185.28970170474
            'feeAmount'       = '612150.465370271'
            'feeAsset'        = '293'
            'feeAudValue'     = '7.15466620747327'
        }
    }
    PROCESS {
        Try {

            $shiba = Get-SwyftxAssetInfo 293
            
            $buyPrice = 0.00001169

            $currentPrice = $memeOrder.amount * $Shiba.sell
            $orderPrice = $memeOrder.amount * $buyPrice
            # $currentValue = $currentPrice - $orderPrice
            $currentValue = $currentPrice - 1200
            
            
            $session = @{
                Sell    = ( "{0:C0}" -f $currentPrice)
                # Ordered = ( "{0:C0}" -f $orderPrice)
                Ordered = ( "{0:C0}" -f 1200)
                Profit  = ( "{0:C0}" -f $currentValue)
                Date    = (Get-Date)
                
            }
            Write-Output $session
            if ($currentValue -gt 1000) { 
                Write-Host -ForegroundColor Green '$$$$$' 
            }
            elseif ($currentValue -gt 100) { 
                Write-Host -ForegroundColor Green '$$$' 
            }
            elseif ($currentValue -gt 30) { 
                Write-Host -ForegroundColor Yellow '$$' 
            }
            elseif ($currentValue -gt 1) { 
                Write-Host -ForegroundColor Red '$' 
            }
            else { '' }
        }
        Catch {
            throw $_
        }
    }
    END { }
}
