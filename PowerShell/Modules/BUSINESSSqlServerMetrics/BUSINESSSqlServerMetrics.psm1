#Requires –Modules Az
#Written by Joshua Van Daalen.
function Get-BUSINESSSqlServerMetrics {
    [cmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$ResourceGroup,

        [Parameter(Mandatory = $false)]
        [string]$ServerName,

        [Parameter(Mandatory = $false)]
        [datetime]$StartDate = (Get-Date).AddDays(-1)
    )

    BEGIN { }
    PROCESS {
        try {
            #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ########################################################
            # Variables
            ########################################################
            $sqlServerParams = @{

                'ServerName'        = $ServerName
                'ResourceGroupName' = $ResourceGroup
                'WarningAction'     = 'SilentlyContinue'
                'ErrorAction'       = 'Stop'
            }

            $sqlDatabaseParams = @{

                'ServerName'    = $ServerName
                'ResourceGroup' = $ResourceGroup
                'WarningAction' = 'SilentlyContinue'
                'ErrorAction'   = 'Stop'
            }
            ########################################################
            if ($ServerName.Length -lt 1) {
                if ($ServerName.Length -lt 1 -and $ResourceGroup.Length -lt 1 ) {
                    ################################################
                    # Get All Sql Servers in All Resource Group on the Subscription
                    ################################################
                    Write-Verbose 'Getting All Sql Servers'
                    $sqlServerList = Get-AzSqlServer
                }
                else {
                    ################################################
                    # Get All Sql Servers in the Resource Group
                    ################################################
                    Write-Verbose "Getting AzSqlServer list in: $($ResourceGroup)"
                    $sqlServerList = Get-AzSqlServer -ResourceGroupName $ResourceGroup
                }

                #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                ####################################################
                # Get All Sql Servers in the Resource Group
                ####################################################
                foreach ($sqlServer in $sqlServerList) {
                    Write-Verbose "Getting BUSINESSSqlServerMetrics for: $($sqlServer.ServerName)"

                    $splats = @{
                        'ResourceGroup' = $sqlServer.ResourceGroupName
                        'ServerName'    = $sqlServer.ServerName
                        'StartDate'     = $StartDate
                        'ErrorAction'   = 'Stop'
                    }

                    Get-BUSINESSSqlServerMetrics @splats
                    ################################################
                }
            }
            else {
                #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                ####################################################
                # Get Sql Server
                ####################################################
                Write-Verbose "Getting AzSqlServer: $($ServerName)"
                $sqlServer = Get-AzSqlServer @sqlServerParams

                Write-Verbose 'Getting Database List'
                $databaseList = Get-AzSqlDatabase @sqlDatabaseParams |
                    Where-Object { $_.DatabaseName -ne 'master' }

                foreach ($sqlDatabase in $databaseList) {
                    Write-Verbose "Getting BUSINESSSqlDatabaseMetrics: $($sqlDatabase.DatabaseName)"

                    $splats = @{
                        'ResourceGroup' = $sqlServer.ResourceGroupName
                        'ServerName'    = $sqlServer.ServerName
                        'DatabaseName'  = $sqlDatabase.DatabaseName
                        'StartDate'     = $StartDate
                        'ErrorAction'   = 'Stop'
                    }

                    Get-BUSINESSSqlDatabaseMetrics @splats

                }
                ####################################################
            }
        }
        catch {
            $_
        }
        finally {
        }
    }
    END {

    }
}
