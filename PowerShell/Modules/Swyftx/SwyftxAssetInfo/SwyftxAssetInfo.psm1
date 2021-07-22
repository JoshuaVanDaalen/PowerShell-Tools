function Get-SwyftxAssetInfo {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory = $True )][string]$AssetId
    )
    BEGIN { }
    PROCESS {
        Try {

            $uri = "https://api.swyftx.com.au/markets/info/basic/$AssetId/"
            $splats = @{
                'Uri'         = $uri
                'Method'      = 'GET'
                'ErrorAction' = 'Stop'
            }

            $session = Invoke-SwyftxRequest @splats
            Write-Output $session
        }
        Catch {
            throw $_
        }
    }
    END { }
}
