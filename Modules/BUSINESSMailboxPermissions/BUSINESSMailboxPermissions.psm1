$LogPreference = "C:\PoSH Logs\BUSINESSMailboxPermissions\Get-BUSINESSMailboxPermissions.txt"

#TODO: Look at the process and foreach loop fininshing after the finally block.
#BUG: When using multiple users there is no distingction between the groups.

function Get-BUSINESSMailboxPermissions{
<#
    .SYNOPSIS

    Get full Mailbox permissions of User.

    .DESCRIPTION

    Enter the Username of the User you want to get mailbox access of, you may specifiy the individual user you're looking for using the Username parameter.

    .EXAMPLE
    
    Set-BUSINESSMailboxPermissions -Username 'UserX' -Mailbox 'UserY'

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
    .LINK
		https://github.com/greenSacrifice/WindowsPowerShell/blob/master/Modules/
#>

    [cmdletBinding()]
    param(

        [Parameter(Mandatory=$True,
                    HelpMessage="Enter The Username of the Mailbox.")] 
                    [String]
                    $UserMailbox,
                    
        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
                   
    #Setting the location of the Organisational Unit.  
    BEGIN{   
            
            Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
            $ErrorsHappened = $false
                                                
          }            
    PROCESS {

       Foreach ($Mailbox in $UserMailbox) {

           Write-Host "$Mailbox's groups." -ForegroundColor Green

                #Find the SamAccountName for the UserMailbox parameter.
                    Try {                                 
                            $Identity = Get-ADUser "$Mailbox" -ErrorAction Stop
                            Write-Verbose "$Identity found."
                        
                        #Do the permissions.
                        Try {
                            #-Identity equals, the Mailbox that -user needs access to.
                            Write-Verbose "Granting $Identity Full Mailbox Access to $Username."
                            Get-MailboxPermission -Identity $Identity.SamAccountName |
							where {$_.accessrights -like 'fullaccess'} |
							select user |
							sort user
                        }
                        
                        Catch {  
                                $ErrorsHappened = $True
                                Write-Verbose "Changes to Mailbox Access Failed."
                                $ADUser | Out-File $ErrorLogFilePath -Append  

                                $Properties = @{Status = "Error happened."
                                                Username = $Username
                                                Mailbox = $Identity.Name}                    
                        }                        
                    }                    
                    Catch {                            
                            $ErrorsHappened = $True
                            Write-Verbose "Changes to Mailbox Access Failed."
                            $Mailbox | Out-File $ErrorLogFilePath -Append       

                            $Properties = @{Status = "The Mailbox wasn't found."
                                            Username = $Username
                                            Mailbox = $Mailbox}                    
                    }                        
            Finally {}
        }
    }

    END {

        if ($ErrorsHappened) {
            
            Write-Verbose "Error has been logged to $ErrorLogFilePath."
        }
    }
}

$LogPreference = "C:\PoSH Logs\BUSINESSMailboxPermissions\Set-BUSINESSMailboxPermissions.txt"

#TODO: Use splatting for readability
#TODO: Update help

function Set-BUSINESSMailboxPermissions{
<#
    .SYNOPSIS

    Grant full Mailbox permissions to User.

    .DESCRIPTION

    Enter the Username of the User you will to give access to, followed by the Mailbox they require access to.

    .EXAMPLE
    
    Set-BUSINESSMailboxPermissions -Username 'UserX' -AccessTo 'UserY'

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
    .LINK
		https://github.com/greenSacrifice/WindowsPowerShell/blob/master/Modules/
#>

    [cmdletBinding()]
    param(

        [Parameter(Mandatory=$True,
                    HelpMessage="Enter The Username of the User requesting access.")] 
                    [String]
                    $Username,

        [Parameter(Mandatory=$True,
                    HelpMessage="Enter The Username of the Mailbox.")] 
                    [String]
                    $AccessTo,
                    
        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
                   
    #Setting the location of the Organisational Unit.  
    BEGIN{   
            
            Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
            $ErrorsHappened = $false
                                                
          }            
    PROCESS {

        Foreach ($User in $Username) {                                                 
            
            #Find the SamAccountName for the Username parameter.
            Try {                    
                    $ADUser = Get-ADUser "$User" -ErrorAction Stop
                    Write-Verbose "$ADUser found."

                Foreach ($Mailbox in $AccessTo) {

                #Find the SamAccountName for the UserMailbox parameter.
                    Try {                                 
                            $Identity = Get-ADUser "$Mailbox" -ErrorAction Stop
                            Write-Verbose "$Identity found."
                        
                        #Do the permissions.
                        Try {
                                #-Identity equals, the Mailbox that -user needs access to.
                                Write-Verbose "Granting $Identity Full Mailbox Access to $ADUser."
                                Add-MailboxPermission -Identity $Identity.SamAccountName -User $ADUser.SamAccountName -AccessRights 'FullAccess' -ErrorAction Stop | Out-Null
                                Add-ADPermission -Identity $Identity.Name -User $ADUser.SamAccountName -AccessRights ExtendedRight -ExtendedRights 'Send-as'-ErrorAction Stop | Out-Null

                                $Properties = @{Status = "Mailbox Access Updated."
                                                Username = $ADUser.SamAccountName
                                                FullAccess = "Enabled"
                                                Mailbox = $Identity.Name}
                        }
                        Catch {  
                                $ErrorsHappened = $True
                                Write-Verbose "Changes to Mailbox Access Failed."
                                $ADUser | Out-File $ErrorLogFilePath -Append  

                                $Properties = @{Status = "Error setting permissions."
                                                Username = $ADUser.SamAccountName 
                                                Mailbox = $Identity.Name}                    
                        }                        
                    }                    
                    Catch {                            
                            $ErrorsHappened = $True
                            Write-Verbose "Changes to Mailbox Access Failed."
                            $Mailbox | Out-File $ErrorLogFilePath -Append       

                            $Properties = @{Status = "The Mailbox wasn't found."
                                            Username = $ADUser.SamAccountName 
                                            Mailbox = $Mailbox}                    
                    }
                }                                 
            }            
            Catch {
                    $ErrorsHappened = $True
                    Write-Verbose "Changes to Mailbox Access Failed."
                    $user | Out-File $ErrorLogFilePath -Append
                    
                    $Properties = @{Status = "Username wasn't found."
                                        Username = $user}                    
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

$LogPreference = "C:\PoSH Logs\BUSINESSMailboxPermissions\Remove-BUSINESSMailboxPermissions"

#TODO: Use splatting for readability
#TODO: Update help

function Remove-BUSINESSMailboxPermissions{
<#
    .SYNOPSIS

    Remove full Mailbox permissions to User.

    .DESCRIPTION

    Enter the Username of the User you to Remove mailbox access, followed by the Mailbox they have access to.

    .EXAMPLE
    
    Remove-BUSINESSMailboxPermissions -Username 'UserX' -Mailbox ''

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
                    HelpMessage="Enter The Username of the User requesting access.")] 
                    [String[]]
                    $Username,

        [Parameter(Mandatory=$True,
                    HelpMessage="Enter The Username of the Mailbox.")] 
                    [String[]]
                    $UserMailbox,
                    
        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
                   
    #Setting the location of the Organisational Unit.  
    BEGIN{   
            
            Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
            $ErrorsHappened = $false
                                                
          }
    PROCESS {

        Foreach ($User in $Username) {                                                 
            
            #Find the SamAccountName for the Username parameter.
            Try {                    
                    $ADUser = Get-ADUser "$User" -ErrorAction Stop
                    Write-Verbose "$ADUser found."

                Foreach ($Mailbox in $UserMailbox) {

                #Find the SamAccountName for the UserMailbox parameter.
                    Try {                                 
                            $Identity = Get-ADUser "$Mailbox" -ErrorAction Stop
                            Write-Verbose "$Identity found."
                        
                        #Do the permissions.
                        Try {
                                #-Identity equals, the Mailbox that -user needs access to.
                                Write-Verbose "Granting $Identity Full Mailbox Access to $ADUser."
                                Remove-MailboxPermission -Identity $Identity.SamAccountName -User $ADUser.SamAccountName -InheritanceType 'All' -AccessRights 'FullAccess' -ErrorAction Stop | Out-Null
                                Remove-ADPermission -Identity $Identity.Name -User $ADUser.SamAccountName -InheritanceType 'All' -ExtendedRights 'send-as' -ChildObjectTypes $null -InheritedObjectType $null -Properties $null -ErrorAction Stop | Out-Null

                                $Properties = @{Status = "Mailbox Access Updated."
                                                Username = $ADUser.SamAccountName
                                                FullAccess = "Disabled"
                                                Mailbox = $Identity.Name}
                        }
                        Catch {  
                                $ErrorsHappened = $True
                                Write-Verbose "Changes to Mailbox Access Failed."
                                $ADUser | Out-File $ErrorLogFilePath -Append  

                                $Properties = @{Status = "Error setting permissions."
                                                Username = $ADUser.SamAccountName 
                                                Mailbox = $Identity.Name}                    
                        }                        
                    }                    
                    Catch {                            
                            $ErrorsHappened = $True
                            Write-Verbose "Changes to Mailbox Access Failed."
                            $Mailbox | Out-File $ErrorLogFilePath -Append       

                            $Properties = @{Status = "The Mailbox wasn't found."
                                            Username = $ADUser.SamAccountName 
                                            Mailbox = $Mailbox}                    
                    }
                }
            }            
            Catch {
                    $ErrorsHappened = $True
                    Write-Verbose "Changes to Mailbox Access Failed."
                    $user | Out-File $ErrorLogFilePath -Append
                    
                    $Properties = @{Status = "Username wasn't found."
                                        Username = $user}                    
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