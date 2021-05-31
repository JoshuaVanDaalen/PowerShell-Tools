
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##########################################################################################
# Set subscription context to testing subscription
$devopstest001 = 'a626fa80-4bbc-4e8e-bc77-0b417f403913'
$Location = 'Australia Southeast'
##########################################################################################
#
Set-AzContext -SubscriptionId $devopstest001

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##########################################################################################
# Creating SQL groups for Azure AD auth on SQL database
# $ADGroupOwner = Get-AzureADUser -SearchString 'joshua@domain.com.au'
# $SqlPowerUserGroupMember = Get-AzureADUser -SearchString 'joshua-sql@domain.com.au'
$randomNumber = (Get-Random).tostring().substring(0, 3)
$ADGroupOwner = Get-AzADUser -UserPrincipalName  'joshua@domain.com.au'
$SqlPowerUserGroupMember = Get-AzADUser -UserPrincipalName 'joshua-test@domain.com.au'

$SqlAdminGroupName = "sql-server-owner-prod"
$SqlPowerUserGroupName = "sql-database-owner-prod"
$SqlUserGroupName = "sql-database-user-prod"
##########################################################################################
#DBA group/ Server owner
New-AzADGroup `
    -DisplayName $SqlAdminGroupName `
    -MailNickName $SqlAdminGroupName
# -MailEnabled $false `
# -SecurityEnabled $true `

# Privliged users group/ database owner
New-AzADGroup `
    -DisplayName $SqlPowerUserGroupName `
    -MailNickName $SqlPowerUserGroupName
# -MailEnabled $false `
# -SecurityEnabled $true `

# Read & Write group/ database user group
New-AzADGroup `
    -DisplayName $SqlUserGroupName `
    -MailNickName $SqlUserGroupName
# -MailEnabled $false `
# -SecurityEnabled $true `

##########################################################################################
# Add group owner
$SqlAdminGroup = Get-AzADGroup -SearchString $SqlAdminGroupName
$SqlPowerUserGroup = Get-AzADGroup -SearchString $SqlPowerUserGroupName
$SqlUserGroup = Get-AzADGroup -SearchString $SqlUserGroupName

# Add-AzureADGroupOwner `
#     -ObjectId $SqlAdminGroup.ObjectId `
#     -RefObjectId $ADGroupOwner.ObjectId    
# Add-AzureADGroupOwner `
#     -ObjectId $SqlPowerUserGroup.ObjectId `
#     -RefObjectId $ADGroupOwner.ObjectId
# Add-AzureADGroupOwner `
#     -ObjectId $SqlUserGroup.ObjectId `
#     -RefObjectId $ADGroupOwner.ObjectId

# ##########################################################################################
# Add group members
Add-AzADGroupMember `
    -MemberObjectId $ADGroupOwner.Id `
    -TargetGroupObjectId $SqlAdminGroup.Id 
# Add-AzADGroupMember `
#     -MemberObjectId $SqlPowerUserGroupMember.Id `
#     -TargetGroupObjectId $SqlPowerUserGroup.Id 
Add-AzADGroupMember `
    -MemberObjectId $SqlPowerUserGroupMember.Id `
    -TargetGroupObjectId $SqlUserGroup.Id 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##########################################################################################
# Create resource group
$ResourceGroupName = "rg-devops-test-$randomNumber"
##########################################################################################
#
New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Tag @{Approver = 'joshuaua Van Daalen'; `
        Environment = "DevOps"; `
        Owner       = 'joshuaua Van Daalen'; `
        Requestor   = 'joshuaua Van Daalen';
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# TallySuper
# someLIKEaPassw0rd
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##########################################################################################
# New SQL server and database
$ServerName = "sql-devops-test-$randomNumber"
$DatabaseName = "sqldb-devops-test-$randomNumber"
$strPass = ConvertTo-SecureString -String "someLIKEaPassw0rd" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('SuperUsernameGoesHere', $strPass)

##########################################################################################
# 
New-AzSqlServer `
    -ServerName $ServerName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SqlAdministratorCredentials $Credential

#
Set-AzSqlServerActiveDirectoryAdministrator `
    -ResourceGroupName $ResourceGroupName `
    -ServerName $ServerName `
    -DisplayName $SqlAdminGroup.DisplayName `
    -ObjectId $SqlAdminGroup.Id    

#
$AzSqlServerFirewallRuleParameters = @{
    'ResourceGroupName' = $ResourceGroupName
    'ServerName'        = $ServerName
    'FirewallRuleName'  = 'FirewallRuleName'
    'StartIpAddress'    = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
    'EndIpAddress'      = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
}
    
New-AzSqlServerFirewallRule @AzSqlServerFirewallRuleParameters

#
New-AzRoleAssignment `
    -ResourceGroupName  $ResourceGroupName `
    -SignInName $SqlPowerUserGroupMember.UserPrincipalName `
    -RoleDefinitionName 'Contributor'

#
New-AzSqlDatabase `
    -ResourceGroupName $ResourceGroupName `
    -ServerName $ServerName `
    -DatabaseName $DatabaseName `
    -ComputeGeneration 'Basic' `
    -Edition 'Basic' `
    -VCore 1

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##########################################################################################
# Connect to SQL server via PowerShell and add group to masterUpdate with 
# Must be run under Azure AD account, do from SSMS
# CREATE USER [$SqlUserGroupName] FROM EXTERNAL PROVIDER; 
##########################################################################################
$AzSqlServerFQDN = (Get-AzSqlServer -ResourceGroupName $ResourceGroupName ).FullyQualifiedDomainName

$Username = 'SuperUsernameGoesHere'
$Passwd = $strPass

$connectionString = "Server=tcp:$AzSqlServerFQDN,1433;" + `
                          "Initial Catalog=$DatabaseName;" + `
                          "Persist Security Info=False;" + `
                          "User ID=$Username;" + `
                          "Password=$Passwd;" + `
                          "MultipleActiveResultSets=False;" + `
                          "Encrypt=True;" + `
                          "TrustServerCertificate=False;" + `
                          "Connection Timeout=30;"
 
Invoke-Sqlcmd `
    -ConnectionString $connectionString `
    -Query 'SELECT * FROM SYS.DATABASE_PRINCIPALS;'

$AzSqlServerFQDN | Clip
Write-Host -ForegroundColor Green "$AzSqlServerFQDN"
Write-Host -ForegroundColor Green "Open SSMS as az server admin, and run`nCREATE USER [$SqlUserGroupName] FROM EXTERNAL PROVIDER;"

# ##########################################################################################
# # ALTER ROLE db_datawriter ADD MEMBER MYUSER 
$Query = "ALTER ROLE db_owner ADD MEMBER [$SqlPowerUserGroupName];"

Invoke-Sqlcmd `
    -ConnectionString $connectionString `
    -Query $Query
# ##########################################################################################
# # GRANT SELECT TO [sql-user-devops-test];
# # GRANT INSERT TO [sql-user-devops-test];
# # GRANT UPDATE TO [sql-user-devops-test];
# # DENY DELETE TO [sql-user-devops-test];
$Query = "GRANT SELECT TO [$SqlUserGroupName];" 
$Query = $Query + "GRANT INSERT TO [$SqlUserGroupName];"
$Query = $Query + "GRANT UPDATE TO [$SqlUserGroupName];"
$Query = $Query + "DENY DELETE TO [$SqlUserGroupName];"
    
Invoke-Sqlcmd `
    -ConnectionString $connectionString `
    -Query $Query

# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


TODO check user-sql-basic can execute sql 


