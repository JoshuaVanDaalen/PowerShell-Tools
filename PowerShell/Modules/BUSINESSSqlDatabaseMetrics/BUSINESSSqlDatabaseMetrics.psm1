#Requires –Modules Az
#Written by Joshua Van Daalen.
function Get-BUSINESSSqlDatabaseMetrics {
    [cmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroup,
        
        [Parameter(Mandatory = $true)]
        [string]$ServerName,

        [Parameter(Mandatory = $false)]
        [string]$DatabaseName = $null,
        
        [Parameter(Mandatory = $false)]
        [datetime]$StartDate = (Get-Date).AddDays(-1)
    )

    BEGIN { }
    PROCESS {

        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ############################################################
        # Variables
        ############################################################
        $Report = New-Object PSCustomObject
         
        $sqlServerParams = @{

            'ServerName'    = $ServerName
            'ResourceGroup' = $ResourceGroup
            'WarningAction' = 'SilentlyContinue'
            'ErrorAction'   = 'Stop'
        }
        
        $sqlDatabaseParams = @{

            'ServerName'    = $ServerName
            'ResourceGroup' = $ResourceGroup
            'WarningAction' = 'SilentlyContinue'
            'ErrorAction'   = 'Stop'
        }

        $metricNames = @{
            'MaxCpuPercent'        = 'cpu_percent'
            'CurrentDTULimit'      = 'dtu_limit'
            'DTUPeakUsage'         = 'dtu_used'
            'MaxStorageGB'         = 'storage'
            'MaxStoragePercentage' = 'storage_percent'
        }
        ############################################################

        try {
            Write-Verbose "Searching AzResourceGroup: $($ResourceGroup)"
          
            if ($DatabaseName.Length -lt 1) {
                #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                ####################################################
                # Get All Sql Databases
                ####################################################
                Write-Verbose "Getting BUSINESSSqlServerMetrics: $($ServerName)"
                Get-BUSINESSSqlServerMetrics @sqlServerParams
                ####################################################
            }
            else {
                #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                ####################################################
                # Get Sql Database
                ####################################################
                Write-Verbose "Getting AzSqlDatabase: $($DatabaseName)"
                $sqlDatabaseParams.DatabaseName = $DatabaseName

                $sqlDatabase = Get-AzSqlDatabase @sqlDatabaseParams |
                    Where-Object { $_.DatabaseName -ne 'master' }

                Write-Verbose "Getting AzResource properties on: $($sqlDatabase.DatabaseName)"
                $resource = Get-AzResource -ResourceId $sqlDatabase.ResourceId -ErrorAction 'Stop'

                $reportParams = @{
                    'MemberType'  = 'NoteProperty'
                    'ErrorAction' = 'Stop'
                }

                $metricParams = @{
                    'Resource'    = $resource
                    'StartDate'   = $StartDate
                    'ErrorAction' = 'Stop'
                }

                ####################################################
                # Set Sroperties
                ####################################################
                $reportParams.Name = 'ServerName'
                $reportParams.Value = $sqlDatabase.ServerName
                $Report | Add-Member @reportParams

                $reportParams.Name = 'DatabaseName'
                $reportParams.Value = $sqlDatabase.DatabaseName
                $Report | Add-Member @reportParams

                $reportParams.Name = 'SKUName'
                $reportParams.Value = $sqlDatabase.CurrentServiceObjectiveName
                $Report | Add-Member @reportParams

                $reportParams.Name = 'SKUCapacity'
                $reportParams.Value = $sqlDatabase.Capacity
                $Report | Add-Member @reportParams
                ####################################################

                foreach ($metricName in $metricNames.GetEnumerator()) {  
                    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    ################################################
                    # Max Cpu Average As Precentage > cpu_percent
                    # Current DTU Limit > dtu_limit
                    # Max DTU used > dtu_used
                    # Max allocated storage > storage
                    # Max allocated storage as percentage > storage_percent

                    #TODO: when looking at max CPU %, note the DTU's being used during that, or just remove this property
                    ################################################
                    Write-Verbose "Getting AzMetrics: $($metricName.Value)"
                    $metricParams.MetricName = $metricName.Value
                
                    $metric = Get-BUSINESSMetric @metricParams
                    
                    if ($metricName.Value -eq 'dtu_limit') {
                        $metric = ($metric |
                                Sort-Object -Property 'TimeStamp' |
                                    Select-Object -Last 1).Average 
                    }
                    else {
                       
                        $metric = $metric | Sort-Object | Select-Object -Last 1
                        
                        if ($metricName.Value -in 'storage', 'storage_percent') {
                            $metric = [math]::Round($metric / 1GB, 2) 

                        } 

                    }
                    Write-Verbose "Metrics: $metric"
                    
                    $reportParams.Name = $metricName.Key
                    $reportParams.Value = $metric
                    $Report | Add-Member @reportParams
                    ################################################

                }
            }

            Write-Verbose 'Output metric data'
            Write-Output $Report
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
