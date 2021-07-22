function Get-SwyftxUserStatistics {
    [cmdletBinding()]
    Param ( )
    BEGIN { }
    PROCESS {
        Try {

            $uri = "https://api.swyftx.com.au/user/statistics/"
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
