function Get-SwyftxHistory {
    [cmdletBinding()]
    Param ( 
        [Parameter(Mandatory = $false )][string]$AssetId = $null
    )
    BEGIN { }
    PROCESS {
        Try {
    
            $historyItems = @()
            $epoch = Get-Date -UFormat %s

            $uri = "https://api.swyftx.com.au/history/all/type/assetId/?from=1616550557&limit=-1&to=$epoch"
            $splats = @{
                'Uri'         = $uri
                'Method'      = 'GET'
                'ErrorAction' = 'Stop'
            }
    
            $session = Invoke-SwyftxRequest @splats -Uri $uri

            foreach ($t in $session) {
                $unixTime = $t.updated.ToString().substring(0, $t.updated.ToString().length - 3)
                $dateTime = [System.DateTimeOffset]::FromUnixTimeSeconds($unixTime)

                $obj = [PSCustomObject]@{
                    'Amount'     = $t.Amount
                    'Quantity'   = $t.Quantity
                    'Asset'      = $t.Asset
                    'Updated'    = $dateTime.LocalDateTime
                    'ActionType' = $t.ActionType
                    'Status'     = $t.Status
                }
                $historyItems += $obj
            }

            $coinbase = Get-CoinbaseHistory 
            $historyItems += $coinbase

            if ($AssetId) {
                $historyItems | Where-Object { $_.Asset -eq $AssetId } 
            }
            else {
                Write-Output $historyItems
            }
        }
        Catch {
            throw $_
        }
    }
    END { }
}
function Get-CoinbaseHistory {
    [cmdletBinding()]
    Param ( )
    BEGIN { 
        # History table
        # Transaction Asset	    Quantity    AUD     Timestamp
        # Buy	        ETH	    0.71689265	250	    2020-07-17T06:18:32Z
        # Buy	        ETH	    0.55395562	250	    2020-07-28T10:03:38Z
        # Buy	        ETH	    0.13813442	72	    2020-08-01T07:29:48Z
        # Send	        ETH	    1.40898269		    2021-05-28T09:24:02Z
        # Buy	        XRP	    167.876285	50	    2020-07-14T17:09:13Z
        # Buy	        XRP	    187.501174	67	    2020-07-30T07:31:57Z
        # Buy	        XRP	    327.708109	142	    2020-08-05T07:04:38Z
        # Send	        XRP	    683.085378		    2021-05-28T09:36:00Z

    }
    PROCESS {
        $historyItems = @()

        $params = @{
            Transaction = 'Coinbase Buy'
            Asset       = '5'
        }

        $params.Quantity = 0.71689265
        $params.AUD = 250
        $params.Timestamp = (Get-Date -Year 2020 -Month 07 -Day 17 -Hour 06 -Minute 18)
        $historyItems += New-CoinbaseCoin @params
        $params.Quantity = 0.55395562
        $params.AUD = 250
        $params.Timestamp = (Get-Date -Year 2020 -Month 07 -Day 28 -Hour 10 -Minute 03)
        $historyItems += New-CoinbaseCoin @params
        $params.Quantity = 0.13813442
        $params.AUD = 72
        $params.Timestamp = (Get-Date -Year 2020 -Month 08 -Day 01 -Hour 07 -Minute 48)
        $historyItems += New-CoinbaseCoin @params

        $params.Asset = '6'
        $params.Quantity = 167.876285
        $params.AUD = 50
        $params.Timestamp = (Get-Date -Year 2020 -Month 07 -Day 17 -Hour 19 -Minute 09)
        $historyItems += New-CoinbaseCoin @params
        $params.Quantity = 187.501174
        $params.AUD = 67
        $params.Timestamp = (Get-Date -Year 2020 -Month 07 -Day 30 -Hour 07 -Minute 31)
        $historyItems += New-CoinbaseCoin @params
        $params.Quantity = 327.708109
        $params.AUD = 142
        $params.Timestamp = (Get-Date -Year 2020 -Month 08 -Day 05 -Hour 07 -Minute 04)
        $historyItems += New-CoinbaseCoin @params

        $params.Transaction = 'Coinbase Transfer'
        $params.Asset = '5'
        $params.Quantity = 1.40898269
        $params.Timestamp = (Get-Date -Year 2021 -Month 05 -Day 28 -Hour 09 -Minute 24)
        $params.AUD = ($historyItems | Where-Object { $_.Asset -eq $params.Asset } | Measure-Object Quantity -sum).sum
        $historyItems += New-CoinbaseCoin @params

        $params.Asset = '6'
        $params.Quantity = 683.085378
        $params.Timestamp = (Get-Date -Year 2021 -Month 05 -Day 28 -Hour 09 -Minute 36)
        $params.AUD = ($historyItems | Where-Object { $_.Asset -eq $params.Asset } | Measure-Object Quantity -sum).sum
        $historyItems += New-CoinbaseCoin @params

        Write-Output $historyItems

    }
    END { }
}
function Get-SwyftxWithdraw {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory = $false )][string]$Asset = 'AUD',
        [Parameter(Mandatory = $false )][datetime]$StartDate = (Get-Date -Date 2021/01/01),
        [Parameter(Mandatory = $false )][datetime]$EndDate = (Get-Date)
    )
    BEGIN {
        $startEpoch = Get-Date -Date $StartDate  -UFormat %s
        $endEpoch = Get-Date -Date $EndDate  -UFormat %s
        while ($startEpoch.Length -lt 13) {
            $startEpoch = $startEpoch + '0'
        }
        while ($endEpoch.Length -lt 13) {
            $endEpoch = $endEpoch + '0'
        }
    }
    PROCESS {
        Try {
            
            $uri = "https://api.swyftx.com.au/history/withdraw/$Asset/?from=$startEpoch&limit=-1&to=$endEpoch"
            $splats = @{
                'Uri'         = $uri
                'Method'      = 'GET'
                'ErrorAction' = 'Stop'
            }
            $session = Invoke-SwyftxRequest @splats
            $session

        }
        Catch {
            throw $_
        }
    }
    END { }
}

function Get-SwyftxDeposit {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory = $false )][string]$Asset = 'AUD',
        [Parameter(Mandatory = $false )][datetime]$StartDate = (Get-Date -Date 2021/01/01),
        [Parameter(Mandatory = $false )][datetime]$EndDate = (Get-Date)
    )
    BEGIN {
        $startEpoch = Get-Date -Date $StartDate  -UFormat %s
        $endEpoch = Get-Date -Date $EndDate  -UFormat %s
        while ($startEpoch.Length -lt 13) {
            $startEpoch = $startEpoch + '0'
        }
        while ($endEpoch.Length -lt 13) {
            $endEpoch = $endEpoch + '0'
        }
    }
    PROCESS {
        Try {

            $uri = "https://api.swyftx.com.au/history/deposit/$Asset/?from=$startEpoch&limit=-1&to=$endEpoch"
            $splats = @{
                'Uri'         = $uri
                'Method'      = 'GET'
                'ErrorAction' = 'Stop'
            }
            $session = Invoke-SwyftxRequest @splats
            $session

        }
        Catch {
            throw $_
        }
    }
    END { }
}

function Get-SwyftxOrder {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory = $false )][datetime]$StartDate = (Get-Date -Date 2021/01/01),
        [Parameter(Mandatory = $false )][datetime]$EndDate = (Get-Date)
    )
    BEGIN {
        $startEpoch = Get-Date -Date $StartDate  -UFormat %s
        $endEpoch = Get-Date -Date $EndDate  -UFormat %s
        while ($startEpoch.Length -lt 13) {
            $startEpoch = $startEpoch + '0'
        }
        while ($endEpoch.Length -lt 13) {
            $endEpoch = $endEpoch + '0'
        }
    }
    PROCESS {
        Try {

            $uri = "https://api.swyftx.com.au/orders/?allOrders=true&rom=$startEpoch&limit=-1&to=$endEpoch"
            $splats = @{
                'Uri'         = $uri
                'Method'      = 'GET'
                'ErrorAction' = 'Stop'
            }
            $session = Invoke-SwyftxRequest @splats
            $session.Orders

        }
        Catch {
            throw $_
        }
    }
    END { }
}
function Get-SwyftxHolding {
    [cmdletBinding()]
    Param ( )
    BEGIN { }
    PROCESS {
        Try {
            
            $swyftDeposit = ((Get-SwyftxDeposit).Amount | Measure-Object -sum).sum
            $withdrawal = ((Get-SwyftxWithdraw).Amount | Measure-Object -sum).sum
            $coinbaseDeposit = ((Get-CoinbaseHistory | Where-Object { $_.ActionType -eq 'Coinbase Buy' }).Quantity | Measure-Object -sum).sum
            
            $deposit = $swyftDeposit + $coinbaseDeposit
            $holding = $deposit - $withdrawal
            $holding
        }
        Catch {
            throw $_
        }
    }
    END { }
}





function New-CoinbaseCoin {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory = $True )][string]$Transaction,
        [Parameter(Mandatory = $True )][string]$Asset,
        [Parameter(Mandatory = $True )][string]$Quantity,
        [Parameter(Mandatory = $false )][string]$AUD = $null,
        [Parameter(Mandatory = $True )][string]$Timestamp
    )
    BEGIN { }
    PROCESS {
        $coin = [PSCustomObject]@{
            'Amount'     = $Quantity
            'Quantity'   = $AUD
            'Asset'      = $Asset
            'Updated'    = $Timestamp
            'ActionType' = $Transaction
            'Status'     = 'Complete'
        }
        Write-Output $coin

    }
    END { }
}