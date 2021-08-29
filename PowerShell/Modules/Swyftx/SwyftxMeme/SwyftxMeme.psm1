function Get-SwyftxMeme {
    [cmdletBinding()]
    Param ( )
    BEGIN {

        $memeOrder = @{
            'orderUuid'       = 'ord_BemmgiWPYtKjSBFFhkJWoo'
            'order_type'      = '1'
            'primary_asset'   = '1'
            'secondary_asset' = '293'
            'quantity_asset'  = '1'
            'quantity'        = '1100'
            'trigger'         = '1.166962511721E-05'
            'status'          = '4'
            'created_time'    = '1629555663934'
            'updated_time'    = '1629555669166'
            'amount'          = 93696240.3691515
            'total'           = '1100'
            'rate'            = '1.166962511721E-0'
            'audValue'        = 1086.16733824375
            'feeAmount'       = '565570.867419425'
            'feeAsset'        = '293'
            'feeAudValue'     = '6.55634208195424'
        }
    }
    PROCESS {
        Try {

            $shiba = Get-SwyftxAssetInfo 293
            
            $buyPrice = 0.0000125

            $currentPrice = $memeOrder.amount * $Shiba.sell
            $orderPrice = $memeOrder.amount * $buyPrice
            # $currentValue = $currentPrice - $orderPrice
            $currentValue = $currentPrice - 1100
            
            
            $session = @{
                Sell    = ( "{0:C0}" -f $currentPrice)
                # Ordered = ( "{0:C0}" -f $orderPrice)
                Ordered = ( "{0:C0}" -f 1100)
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
