#Written by Joshua Van Daalen.
function Get-BUSINESSSqlConnectionString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ServerName,
        [Parameter(Mandatory)][string]$DatabaseName,
        [Parameter(Mandatory)][string]$DatabaseUser,
        [Parameter(Mandatory)][string]$DatabasePasswd
    )
    process {
        if (-not $ServerName.EndsWith(".database.windows.net")) {
            $ServerName = "$($ServerName).database.windows.net"
        }

        [string] $connectionString = `
            "Server=tcp:$ServerName,1433;" + `
            "Initial Catalog=$DatabaseName;" + `
            "Persist Security Info=False;" + `
            "User ID=$DatabaseUser;" + `
            "Password=$DatabasePasswd;" + `
            "MultipleActiveResultSets=False;" + `
            "Encrypt=True;" + `
            "TrustServerCertificate=False;" + `
            "Connection Timeout=5000;"

        return $connectionString
    }
}
