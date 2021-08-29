function Invoke-SwyftxRequest {
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory = $True )][string]$Uri,
        [Parameter(Mandatory = $True )][string]$Method,
        [Parameter(Mandatory = $False )][hashtable]$Headers,
        [Parameter(Mandatory = $False )][string]$Body = $null
    )
    BEGIN {
        $accessToken = Get-SwyftxAccessToken
    }
    PROCESS {
        Try {

            $Headers += @{
                'Authorization' = $accessToken
                # 'user-agent'    = 'pwsh'
                'Content-Type'  = 'application/json'
            }

            $splats = @{
                'Uri'         = $Uri
                'Method'      = $Method
                'Headers'     = $Headers 
                'Body'        = $Body
                'ErrorAction' = 'Stop'
            }
            
            $session = Invoke-RestMethod @splats
            Write-Output $session
        }
        Catch {
            throw $_
        }
    }
    END {
        Remove-SwyftxAccessToken -Token $accessToken |
            Out-Null
        # $host.ui.RawUI.WindowTitle = "$Subscription - $($context.Account.Id) - $((Get-Date).ToShortDateString())"
    }
}
