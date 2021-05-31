

$ResourceGroupName = 'rg-tally-shared'
$ServerName = "sql-tally-test"
$strPass = ConvertTo-SecureString -String "something that looks like a password" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('the username for super user', $strPass)

New-AzSqlServer `
    -ServerName $ServerName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SqlAdministratorCredentials $Credential

$SqlAdminGroupName = "sql-server-admin-test"
$SqlWriterGroupName = "sql-server-datawriter-test"
$SqlReaderGroupName = "sql-server-datareader-test"

$GroupNames = @(
    $SqlAdminGroupName
    $SqlWriterGroupName
    $SqlReaderGroupName
)

foreach ($group in $GroupNames) {
    New-AzADGroup `
        -DisplayName $group `
        -MailNickName $group
}

$SqlAdminGroup = Get-AzADGroup -SearchString $SqlAdminGroupName

Set-AzSqlServerActiveDirectoryAdministrator `
    -ResourceGroupName $ResourceGroupName `
    -ServerName $ServerName `
    -DisplayName $SqlAdminGroup.DisplayName `
    -ObjectId $SqlAdminGroup.Id


# CREATE USER [sql-server-admin-test] FROM EXTERNAL PROVIDER;
# CREATE USER [sql-server-datareader-test] FROM EXTERNAL PROVIDER;
# CREATE USER [sql-server-datawriter-test] FROM EXTERNAL PROVIDER;