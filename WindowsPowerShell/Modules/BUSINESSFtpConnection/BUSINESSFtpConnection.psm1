#Requires -Version 7.0
#Written by Joshua Van Daalen.
function Test-BUSINESSFtpConnection {
    [CmdletBinding()]
    param (
        [Parameter( Mandatory = $true)]
        [String]
        $Username,

        [Parameter( Mandatory = $true)]
        [String]
        $Password,

        [Parameter( Mandatory = $false)]
        [String]
        $FtpServer
    )    
    begin { }
    process {     
        if ($FtpServer.Length -gt 0) {
            $ftprequest = [System.Net.FtpWebRequest]::Create("ftp://$FtpServer")
            $ftprequest.Credentials = New-Object System.Net.NetworkCredential("$Username", "$Password")
            $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::PrintWorkingDirectory
            $ftprequest.GetResponse()            
        }
        else {            
            $Env = (Read-Host -Prompt "Type PROD or UAT").ToUpper()
            $FtpServer = ($Env -eq 'PROD' `
                    ? '123.123.123.123' `
                    : $Env -eq 'UAT' `
                    ? '222.222.222.222' : $null)
            Write-Host -ForegroundColor Green "Testing FTP connection: $FtpServer"
            if ($null -eq $FtpServer) { throw "Environment was not 'PROD' or 'UAT'" }
            Test-BUSINESSFtpConnection `
                -Username $Username `
                -Password $Password `
                -FtpServer $FtpServer
        }
    }
    end { }
}
