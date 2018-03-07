$LogPreference = "C:\PoSH\ADGroupMember\Add-ADGroupMember.txt"

#TODO: Update comment block.
#TODO: Update params Help Messages.
Function Add-BUSINESSADGroupMember {

<#
    .Synopsis
    Adds Mail Contacts to a Distibuton Group via CSV file 
    .DESCRIPTION
    The New-BUSINESSDistributionGroupMember function uses a CSV file to populate a Distribution Group.

    Mandatory parameters are used to locate the file path of the CSV, and identitfy what Distribution Group you are changing.

    This function uses the CSV file to collect Email Addresses and find if they have a Mail Contact that can be added to the chosen Distribution Group, the Email Addresses that don't have a Mail Contact and listed in the error log file path and displayed in the console window.

    .EXAMPLE
        Set-BUSINESSDistributionGroupMember -Username 'UserX' -DistributionGroup "All Australian Users"
    .NOTES
    You need to have the exchange module to use this function.
#>

    [cmdletBinding()]
    param(
        #Path that contains the CSV file.
        [Parameter(Mandatory=$True,
                    HelpMessage="Enter The File Path of CSV Document")] 
                    [String[]]
                    $Username,
            
        #Distribution Group that will be appended.
        [Parameter(Mandatory=$True,
                    HelpMessage="Enter The Distibution Group")] 
                    [String[]]
                    $DistributionGroup,

        #Creates an Object for the error path variable.
        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
    BEGIN {
    
                Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
                $ErrorsHappened = $false

    }
    PROCESS {
        Foreach ($User in $Username) {
  
            Try {                      
                    
                $ADUser = Get-ADUser "$User" -Properties mail

                Try { 

                    $Session = Add-ADGroupMember -Identity "$DistributionGroup" -Member "$ADUser.name" -ErrorAction Stop

                    # A Hash tabel is created to that is used to output the data to the console.
                    $Properties = @{Status = "Member added"
                                    Email = $ADUser.name
                                    DistributionGroup = $DistributionGroup} 

                    }
                Catch {
                        
                    $DistributionGroup | Out-File $ErrorLogFilePath -Append
                    $ErrorsHappened = $True

                    $Properties = @{Status = "$DistributionGroup not found"
                                    Email = $ADUser.name
                                    DistributionGroup = $null}                        
                }
            }
            Catch {
                                        
                $Email.PrimarySMTPAddress | Out-File $ErrorLogFilePath -Append
                $ErrorsHappened = $True

                $Properties = @{Status = "$User not found"
                                Email = $null
                                DistributionGroup = $null} 
            }
            Finally{    
                                
                if($ErrorsHappened = $True) { 

					$obj = New-Object -TypeName PSObject -Property $Properties  
					Write-Output $obj 
                }

                elseif ($ErrorsHappened = $false) {
                                
                    $obj = New-Object -TypeName PSObject -Property $Properties
                    Write-Output $obj                               

                }
            }
		}
    }
    END {
        if ($ErrorsHappened) {

			Write-verbose "Error has been logged to $ErrorLogFilePath."
        }
    }
}

$LogPreference = "C:\PoSH\ADGroupMember\Copy-ADGroupMember.txt"

#TODO: Update comment block.
#TODO: Update params Help Messages.
Function Copy-BUSINESSADGroupMember {

<#
    .Synopsis
    Copy an exsisting Users Security & Distribution Groups to another User.
    .DESCRIPTION
    The Copy-ADGroupMember function uses an exsisting Active Directory Account's Groups to populate another AD Users Groups.
            
    .EXAMPLE
    Copy-ADGroupMember -From 'UserX' -To 'UserY'

    .NOTES
    You need to have the exchange module to use this function.
#>

    [cmdletBinding()]
    param(        
        [Parameter(Mandatory=$True,
                    HelpMessage="Who's groups do you want to copy?")] 
                    [String]
                    $From,
            
        #Distribution Group that will be appended.
        [Parameter(Mandatory=$True,
                    HelpMessage="What User is recieving these Groups?")] 
                    [String]
                    $To,

        #Creates an Object for the error path variable.
        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
    BEGIN {
    
                Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
                $ErrorsHappened = $false
    }
    PROCESS {

        Write-Host "Adding the following groups to $To" -ForegroundColor Green 

            Try {
                    
                #Get the From User's groups.
                $FromUser = Get-ADUser $From -Properties * -ErrorAction Stop

                Try { 
                        
                    #Get the To User.
                    $ToUser = Get-ADUser $To -Properties * -ErrorAction Stop
                    $ToUsername = $ToUser.SamAccountName

                    Try {
                        
                        #Send each group to the Add group cmdlet.
                        Foreach ($Group in $FromUser.MemberOf) {
                            
                            $Pos = $Group.IndexOf(",")
                            $Trim = $Group.Substring(0, $Pos)

							Add-ADGroupMember -Identity $Group -Member $ToUsername -ErrorAction Stop
							Write-Host "$Trim" -ForegroundColor Cyan
                                                                            
                        }
                    }
                    Catch {
                        
                        $FromUser.MemberOf | Out-File $ErrorLogFilePath -Append
                        $ErrorsHappened = $True

                        Write-Host "Failed to Add $Group to $To." -ForegroundColor Red
                    }                 
                }
                Catch {
                                        
                    $ToUsername | Out-File $ErrorLogFilePath -Append
                    $ErrorsHappened = $True

                    Write-Host "Failed to find $ToUsername." -ForegroundColor Red                    
                }
            }
            Catch {                                      

                $From | Out-File $ErrorLogFilePath -Append
                $ErrorsHappened = $True

                Write-Host "Failed to find $From." -ForegroundColor Red 
            }            
            Finally{
			}
        }
    END {
        if ($ErrorsHappened) {

            Write-verbose "Error has been logged to $ErrorLogFilePath."

        }
    }
}

$LogPreference = "C:\PoSH\ADGroupMember\Remove-BUSINESSADGroupMember.txt"
$Filepath = "C:\PoSH\ADGroupMember\BackupLogs"

#TODO: Add a foreach to the process block to allow mulitple users.
#TODO: Update comment block.
#TODO: Update params Help Messages.
Function Remove-BUSINESSADGroupMember {

<#
    .Synopsis
        Remove an exsisting Users Security & Distribution Groups.
    .DESCRIPTION
    The Remove-BUSINESSADGroupMember function uses an exsisting Active Directory Account's Groups to populate another AD Users Groups.
            
    .EXAMPLE
        Remove-BUSINESSADGroupMember -Username 'UserX'

    .NOTES
    You need to have the exchange module to use this function.
#>

    [cmdletBinding()]
    param(
        #Path that contains the CSV file.
        [Parameter(Mandatory=$True,
                    HelpMessage="Who's groups do you want to copy?")] 
                    [String[]]
                    $Username,        

        #Creates an Object for the error path variable.
        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)
    BEGIN {
    
        Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
        $ErrorsHappened = $false
        $Filepath = "$Filepath\Removed\$Username BackupOfGroups.txt"        
    }
    PROCESS {
        Try {
                    
			#Get the From User's groups.
			$ADUser = Get-ADUser "$Username" -Properties * -ErrorAction Stop
			$SamAccountName = $ADuser.SamAccountName
			$MemberOf = $ADUser.MemberOf
			$ErrorsHappened = "$FALSE"
                                
            Try {
                        
                #Backup the Users Groups to file path.
                Foreach ($Group in $MemberOf) {

                    $Group | Out-File $Filepath -Append -ErrorAction stop 
                    $ErrorsHappened = "$FALSE"
                }

		        Write-Host "$SamAccountName's groups backed up to $Filepath" -ForegroundColor Green
		        Write-Host "Removing the following groups from $SamAccountName" -ForegroundColor Green 

                Try {
                            
                    #Send each group to the Add group cmdlet.
                    Foreach ($Group in $MemberOf) {

                        $Pos = $Group.IndexOf(",")
                        $Trim = $Group.Substring(0, $Pos)
                            
                        Remove-ADGroupMember -Identity $Group -Member $SamAccountName -Confirm:$False -ErrorAction Stop
                        Write-Host "$Trim" -ForegroundColor Cyan   
                        $ErrorsHappened = "$FALSE" 
                    }
                }

                Catch {
                        
                    $SamAccountName | Out-File $ErrorLogFilePath -Append
                    $ErrorsHappened = $TRUE
                    Write-Host "Failed to remove $SamAccountName's groups, exiting function." -ForegroundColor Red
                }
            }
            Catch {
                                        
                $SamAccountName | Out-File $ErrorLogFilePath -Append
                $ErrorsHappened = $TRUE
                Write-Host "Failed to backup $SamAccountName's groups, exiting function." -ForegroundColor Red
            }
        }
        Catch {                                      

            $Username | Out-File $ErrorLogFilePath -Append
            $ErrorsHappened = $True

            Write-Host "Failed to find $Username." -ForegroundColor Red 
        }
                    
        Finally{
        }
    }
    END {
        if ($ErrorsHappened) {

			Write-verbose "Error has been logged to $ErrorLogFilePath."
        }
    }
}