function Get-SwyftxAccessToken {
    [cmdletBinding()]
    Param ( )
    BEGIN { }
    PROCESS {
        try { 
            $Uri = 'https://api.swyftx.com.au/auth/refresh/'
            $Headers = @{ 
                # 'user-agent'   = 'pwsh' 
                'Content-Type' = 'application/json'
            }
            $Body = '{"apiKey": "GFNqjK2HCqcu_4wNl6Kxdz1rx3C4Vp6CG_JJoldvr48Uq"}'
            $Method = 'POST'
            
            $splats = @{
                'Uri'         = $Uri
                'Method'      = $Method
                'Headers'     = $Headers
                'Body'        = $Body
                'ErrorAction' = 'Stop'
            }
            
            $session = Invoke-RestMethod @splats
            $accessToken = "Bearer $($session.accessToken)"
      
            Write-Output $accessToken
        }
        catch { 
            # $err = $_.Exception
            # throw $err
            throw $_

        }
    }
    END { }
}

function Remove-SwyftxAccessToken {
    [cmdletBinding()]    
    Param (
        [Parameter(Mandatory = $True )][string]$Token
    )
    BEGIN { }
    PROCESS {
        try { 
            $Uri = 'https://api.swyftx.com.au/auth/logout/'
            $Headers = @{ 
                'user-agent'    = 'pwsh' 
                'Authorization' = $Token
            }
            $Body = $null
            $Method = 'POST'
            
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
        catch { 
            # $err = $_.Exception
            # throw $err
            throw $_

        }
    }
    END { }
}