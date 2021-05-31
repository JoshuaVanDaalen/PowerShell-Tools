#Written by Joshua Van Daalen.

function Invoke-BUSINESSSqlCmd {
  [cmdletBinding()]
  param(
    [Parameter(Mandatory = $True, HelpMessage = "Enter the connection string to the SQL server.")]
    [String] $ConnectionString,

    [Parameter(Mandatory = $True, HelpMessage = "Enter the sql query.")]
    [String] $Query
  )

  BEGIN { }
  PROCESS {
    Try {
      $session = Invoke-Sqlcmd `
        -ConnectionString $ConnectionString `
        -Query $Query
    }
    Catch {
      $_.Exception.Message
      $_.Exception.ItemName
      ""
      $_
    }
    Finally {
      $session
    }
  }
  END { }
}
