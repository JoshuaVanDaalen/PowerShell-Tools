# Get-BUSINESSUser
	<#
	
	$Properties = "SamAccountname","PrimarySTMPAddress","DisplayName"
	Get-ADUser -filter * -Property $Properties | Format-List

	#>

# New-BUSINESSUser
    #TODO: Test Office path is true, if not end script
	#TODO: Change the Office attribute location to top????

<#NOTE:	Change BUSINESS to the companies business name
		Change $UserPrincipalName to companies Email Address
		Change $Office to correct Organisational Units
#>

$LogPreference = "C:\PoSH Logs\BUSINESSUser\New-BUSINESSUser.csv"
function New-BUSINESSUser{
<#
    .SYNOPSIS

    Create a new Active Directory User and Mailbox.

    .DESCRIPTION

    Running this function creates a Active Directory account and Exchange Mailbox.
	The AD Account is assinged to the Organisational Unit given in the Office parameter.

    .EXAMPLE

    New-BUSINESSUser 

    .EXAMPLE

    New-BUSINESSUser -GivenName 'User' -Surname 'X' -Office 'Melbourne'

    .INPUTS
    Inputs to this cmdlet (if any)
    .OUTPUTS
    Output from this cmdlet (if any)
    .NOTES
    General notes
    .COMPONENT
    The component this cmdlet belongs to
    .ROLE
    The role this cmdlet belongs to
    .FUNCTIONALITY
    The functionality that best describes this cmdlet
#>

    [cmdletBinding()]
    param(

        [Parameter(Mandatory=$True,
                    HelpMessage="Enter the users first name.")]
                    #[Alias ('FirstName')]
                    [String]
                    $GivenName,

        [Parameter(Mandatory=$True,
                    HelpMessage="Enter the users last name.")]
                    #[Alias ('LastName')]
                    [String]
                    $Surname,                        
                        
        [Parameter(Mandatory=$True,
                    HelpMessage="Enter the Office")]
                    [String]
                    $Office, 

        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
                    
    BEGIN{   

        Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
        $ErrorsHappened = $false

    }
                
    PROCESS {

        Foreach ($User in $GivenName) {
                
            #Capitilise the Users Given Name's first letter.
            $FirstName = ($GivenName.Substring(0,1).toupper() + $GivenName.Substring(1).tolower()) 
            #Capitilise the Users Surname Name's first letter.
            $LastName = ($Surname.Substring(0,1).toupper() + $Surname.Substring(1).tolower())
            #Create a Username for the User using the firstname and first letter of last name.
            $SamAccountName = $FirstName + $LastName.Substring(0, 1)
            $DisplayName = "$FirstName $LastName"
            $UserPrincipalName = $SamAccountName + '@BUSINESS.com'     
            $Office = $Office                             
            #Prompt to enter password.
            $Password = Read-Host -AsSecureString "Enter Password for $SamAccountName"
                
            switch ($Office) {
                        
                'OFFICE1'
                    
                    {$OrganizationalUnit = "OU=OFFICE1,OU=COUNTRY,OU=USERS,OU=BUSINESS,DC=LOCAL,DC=DOMAIN,DC=COM,DC=AU"}
                    
                'OFFICE2'
            
                    {$OrganizationalUnit =  "OU=OFFICE2,OU=COUNTRY,OU=USERS,OU=BUSINESS,DC=LOCAL,DC=DOMAIN,DC=COM,DC=AU"}
                    
                'OFFICE3'
            
                    {$OrganizationalUnit =  "OU=OFFICE3,OU=COUNTRY,OU=USERS,OU=BUSINESS,DC=LOCAL,DC=DOMAIN,DC=COM,DC=AU"}
                }
                    
            #Create ADUser and Enable Mailbox.
            Try {
                    Write-Host ""
                    Write-Host "Creating New User $SamAccountName."-foregroundcolor "green"

                    #Create a hash table to splat into Cmdlet with our given parameters.
                    $Parameters = @{'Alias' = $SamAccountName
                                    'FirstName' = $FirstName
                                    'LastName' =$LastName
                                    'Name' = $DisplayName
                                    'OrganizationalUnit' = $OrganizationalUnit 
                                    'Password' = $Password
                                    'ResetPasswordOnNextLogon' = $false
                                    'SamAccountName' = $SamAccountName
                                    'UserPrincipalName' = $UserPrincipalName
                                    'ErrorAction' = 'Stop'}
                                        
                    $ADUser =  New-Mailbox  @Parameters
                                                    
                    #Specific values to be stored in $Properties Object.
                    $Properties = @{Status = "User Successfully Created"
                                        Username = $SamAccountName
                                        DisplayName = $DisplayName
                                        UserEnabled = $True
                                        MailboxEnabled = $True
                                        Email = $Email
                                        OrganizationalUnit = $OrganizationalUnit}
            }
                
            #Error happened.
            Catch {

                    $ErrorsHappened = $True
                    Write-Host "Couldn't create new user $SamAccountName." -ForegroundColor 'red'
                    $SamAccountName | Out-File $ErrorLogFilePath -Append

                    Write-Output "Attemping to locate existing user with same Username."
                    $FoundUser = Get-ADUser -filter {SamAccountName -eq $SamAccountName} -Properties * -erroraction silentlycontinue
                        
                    $Properties = @{Status = 'Errors Creating New User.'
                    Username = $SamAccountName
                    DisplayName = $null
                    UserEnabled = $null
                    MailboxEnabled = $null
                    Email = $FoundUser.mail
                    FoundUser = $FoundUser
                    UserCreated = $FoundUser.whenCreated}                        
            }
                            
            Finally {
                                        
                    $obj = New-Object -TypeName PSObject -Property $Properties

                    Write-Output $obj                             
            }
        }
    }

    END {

        if ($ErrorsHappened) {
                
            Write-Verbose "Error has been logged to $ErrorLogFilePath."
        }
    }
}
   

# Set-BUSINESSUser
    #TODO: Set optional parameters, give unused parameters current value
	#TODO: Update Description

<#NOTE:	Change $UserPrincipalName to companies Email Address
		Change $Office to correct Organisational Units
#>

$LogPreference = "C:\PoSH Logs\BUSINESSUser\Set-BUSINESSUser.csv"
function Set-BUSINESSUser{

<#
    .SYNOPSIS

    Change a users Active Directory details.

    .DESCRIPTION

    Using a CSV file change the users Active Directory details. 

    .EXAMPLE

    Set-BUSINESSUser 

    .EXAMPLE

    Set-BUSINESSUser -GivenName 'User' -Surname 'X' -Office 'AUManager'

    .INPUTS
    Inputs to this cmdlet (if any)
    .OUTPUTS
    Output from this cmdlet (if any)
    .NOTES
    General notes
    .COMPONENT
    The component this cmdlet belongs to
    .ROLE
    The role this cmdlet belongs to
    .FUNCTIONALITY
    The functionality that best describes this cmdlet
#>

[cmdletBinding()]
param(

    [Parameter(Mandatory=$True,
                HelpMessage="Enter the users first name.")]
                [String]
                $GivenName,

    [Parameter(Mandatory=$True,
                HelpMessage="Enter the users last name.")]
                [String]
                $Surname,                        
                    
    [Parameter(Mandatory=$True,
                HelpMessage="Enter the users office.")]
                [String]
                $Office,

    [Parameter(Mandatory=$True,
                HelpMessage="Enter the users job description.")]
                [String]
                $Description,

    [Parameter(Mandatory=$false)]
                [String]
                $Department,
            
    [Parameter(Mandatory=$false)]
                [String]
                $Title,                    
                        
    [Parameter()]
                [String]
                $ErrorLogFilePath = $LogPreference)

    BEGIN {

        Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
        $ErrorsHappened = $false
    }

    PROCESS {

        Foreach ($User in $GivenName) {                
            Try {
                    
                #Capitilise the Users Given Name's first letter.
                $FirstName = ($GivenName.Substring(0,1).toupper() + $GivenName.Substring(1).tolower()) 
                #Capitilise the Users Surname Name's first letter.
                $LastName = ($Surname.Substring(0,1).toupper() + $Surname.Substring(1).tolower())
                #Create a Username for the User using the firstname and first letter of last name.
                $SamAccountName = $FirstName + $LastName.Substring(0, 1)
                $DisplayName = "$FirstName $LastName"
                $Email = $SamAccountName + '@BUSINESS.com'

                if ($Department.Length -le 1) { 
                        
                    $Department = " "                        
                }
                    elseif ($Department.Length -gt 1){

                        $Department = "$Department"
                    }
                    if ($Title.Length -le 1) { 
                            
                        $Title = " "
                    }
                        elseif ($Department.Length -gt 1){

                            $Title = "$Title"
                        }                    
                        switch ($Office) {
                                
                            'OFFICE1'
                                
                                {$City = 'Melbourne'
                                $State = 'Victoria'
                                $Country = 'AU'}
                                
                            'OFFICE2'
                        
                                {$City = 'Melboune'
                                $State = 'Victoria'
                                $Country = 'AU'}
                                
                            'OFFICE3'
                        
                                {$City = 'Melbourne'
                                $State = 'Victoria'
                                $Country = 'AU'}
                            }
                                                            
                            $Parameters = @{'City' = "$City"                
                                            'Country' = "$Country"
                                            'Department' = "$Department"
                                            'Description' = $Description
                                            'DisplayName' = "$DisplayName"
                                            'EmailAddress' = "$Email"
                                            'GivenName' = "$FirstName"
                                            'Identity' = "$SamAccountName"
                                            'Office' = "$Office"
                                            'SamAccountName' = "$SamAccountName"
                                            'State' = "$State"
                                            'Surname' = "$LastName"
                                            'Title' = "$Title"
                                            'ErrorAction' = "stop"}

                        $ADUser = Set-ADUser @Parameters

                        $Properties = @{'City' = "$City"                
                                        'Country' = "$Country"
                                        'Department' = "$Department"
                                        'Description' = $Description
                                        'DisplayName' = "$DisplayName"
                                        'EmailAddress' = "$Email"
                                        'GivenName' = "$FirstName"
                                        'Identity' = "$SamAccountName"
                                        'Office' = "$Office"
                                        'Username' = "$SamAccountName"
                                        'State' = "$State"
                                        'Surname' = "$LastName"
                                        'Title' = "$Title"}                
                        }
                Catch {

                    $ErrorsHappened = $True
                    Write-Verbose "Couldn't find $user."
                    $User | Out-File $ErrorLogFilePath -Append

                    $Properties = @{'User' = $null
                                    'Status' = 'Failed to update User'
                                    'EmailAddress' = $null}
                }
                Finally {

                    $obj = New-Object -TypeName PSObject -Property $Properties

                    Write-Output $obj
                }
            }
        }

    End {

        if ($ErrorsHappened) {
                
            Write-Verbose "Error has been logged to $ErrorLogFilePath."
        }
    }
}


# Remove-BUSINESSUser

<#1. Request deactivation of Jira account
2. Request deactivation of Sap account
3. Forward email accordingly
4. Export pst, we only forward emails 90 days in US than we export PST and delete mailbox 
5. Remove user from all Distrbution groups
6. Remove user from all Security groups
7. Disable AD user, move to disabled user folder
8. Reset PW
9. Remove Office 365 Subscription
Out of office reply (if account is disabled Out of office reply’s don’t work)
#>