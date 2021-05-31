#Requires –Modules Az
#Written by Joshua Van Daalen.
$date = Get-Date
function Get-BUSINESSMetric {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$MetricName,

        [Parameter(Mandatory = $True)]
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResource]$Resource,
        
        [Parameter(Mandatory = $false)]
        [datetime]$StartDate = ($date).AddDays(-1)        
    )
    BEGIN { }
    PROCESS {

        $spalts = @{
            'MetricName'    = $MetricName
            'StartTime'     = $StartDate
            'EndTime'       = $date
            'WarningAction' = 'SilentlyContinue'
            'ErrorAction'   = 'Stop'
        }

        Write-Verbose "Getting AzMetric for: $($Resource.Name)"
        Write-Verbose "Metric Name: $MetricName"
        
        if ($MetricName -in 'cpu_percent', 'dtu_used' ) { 
            $type = 'Average' 
            Write-Verbose "Metric type: $type"
        }
        elseif ($MetricName -in 'storage', 'storage_percent' ) {
            $type = 'Maximum' 
            Write-Verbose "Metric type: $type"
        }
        else { 
            $type = $null 
            Write-Verbose 'Metric type: NULL/ Full Data'
        }
        try {
            Write-Verbose "Getting AzMetrics: $MetricName"
            $metric = $Resource | Get-AzMetric @spalts
            Write-Verbose "metric = $metric "

            switch ($type) {
                'Average' { 
                    Write-Verbose "Getting type data: $type"
                    $session = $metric.Data.Average 
                    break
                }
                'Maximum' {
                    Write-Verbose "Getting type data: $type"
                    $session = $metric.Data.Maximum 
                    break
                }
                Default { 
                    Write-Verbose 'Getting type data: NULL/ Full Data'
                    $session = $metric.Data 
                    break
                }
            }
            Write-Output $session
        }
        catch { }
    }
    END { }
}
