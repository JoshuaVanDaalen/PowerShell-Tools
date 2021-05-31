$sqlServerName = 'sql-public-159357789'
$dbResourceGroupName = 'TallyDBResources'

Get-AzSqlDatabase -ServerName $sqlServerName  -ResourceGroupName $dbResourceGroupName |
        Where-Object { $_.DatabaseName -notlike '*org-dev*' `
                        -and $_.DatabaseName -like '*org-*' `
                        -and $_.DatabaseName -notlike '*org-uat*' `
                        -and $_.DatabaseName -notlike '*sandbox*' } |
                ForEach-Object { $sqlDatabaseName = $_.DatabaseName; New-AzResourceLock `
                                -LockLevel CanNotDelete `
                                -LockName "$($_.DatabaseName.ToLower())-lock" `
                                -ResourceName "$sqlServerName/$sqlDatabaseName" `
                                -ResourceGroupName $_.ResourceGroupName `
                                -LockNotes 'Lock on database to prevent deleting.' `
                                -ResourceType 'Microsoft.Sql/servers/databases' `
                                -WhatIf
                }
