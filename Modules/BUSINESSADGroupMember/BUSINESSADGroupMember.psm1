﻿$LogPreference = "C:\PoSH\BUSINESSADGroupMember"

Function Add-BUSINESSADGroupMember {

<#
    .Synopsis
	    Add a user to a Active Directory group.

    .DESCRIPTION
		The Add-BUSINESSADGroupMember function accepts an array of usernames that will be added to the Active Directory Group you choose.

    .EXAMPLE
		Add-BUSINESSADGroupMember -Username 'UserX' -ADGroup "GroupY"
    
	.NOTES
		You need to have the Exchange module to use this function.
		You need to have the Active Directory module to use this function.

	.LINK
		https://github.com/greenSacrifice/WindowsPowerShell/blob/master/Modules/BUSINESSADGroupMember/BUSINESSADGroupMember.psm1
#>

    [cmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
                    HelpMessage="Enter Username")] 
                    [String[]]
                    $Username,
            
        [Parameter(Mandatory=$True,
                    HelpMessage="Enter Distibution Group")] 
                    [String]
                    $ADGroup,

        [Parameter()]
                    [String]
                    $ErrorLogFilePath = $LogPreference)

    BEGIN {
    
		Write-Verbose "Testing if error path exists."
		$FullLogPath = "$ErrorLogFilePath\Add-ADGroupMember.txt"
		$PathBool = Test-Path -Path $FullLogPath
		$Date = Get-Date

		if ($PathBool) {

			Write-Verbose "Log path exists."
		}
		elseif ($PathBool = "$false") {

			Write-Verbose "Creating error log directory."
			New-Item -Path "$FullLogPath" -ItemType 'File' -Force | Out-Null
			Write-Verbose "Error log directory created."
		}
    }
    PROCESS {
        Foreach ($User in $Username) {
			Write-Verbose "Iterating each user in username array."
  
            Try {                      
                 
				Write-Verbose "Testing if $User exists."
                $ADUser = Get-ADUser -Identity "$User" -Properties 'mail' -ErrorAction 'Stop'
				$Member = $ADUser.Name
				$SamAccountName = $ADUser.SamAccountName 
				Write-Verbose "$Member located."

				Try{
					
					Write-Verbose "Testing if $ADGroup exists."
					$Group = Get-ADGroup -Identity "$ADGroup" -ErrorAction 'Stop'
					$Identity = $Group.SamAccountName
					Write-Verbose "$Identity located."

					Try {

						Write-Verbose "Attempting to add $SamAccountName to $Identity."
						$Session = Add-ADGroupMember -Identity "$Identity" -Member "$SamAccountName" -ErrorAction 'Stop'
						Write-Verbose "$Member added to $Identity successfully."

						Write-Verbose "Build custom object properties."
						$Properties = @{
												Status = "Member added"
												Username = $SamAccountName
												Name = $Member
												Group = $Identity}
					}
					Catch {
                        
						Write-Verbose "Failed to add $Member to $Identity."
						Write-Verbose "Appending error log."
						"$Member Was not added to $Identity." | Out-File $FullLogPath -Append
						"$Date" | Out-File $FullLogPath -Append
						$ErrorsHappened = $True

						Write-Verbose "Build custom object properties."
						$Properties = @{
												Status = "Failed to add $SamAccountName"
												Username = "$SamAccountName"
												Name = "$Member"
												Group = "$Identity"}
					}
				}
				Catch {

					Write-Verbose "$ADGroup was not found."
					Write-Verbose "Appending error log."
					"$ADGroup was not found." | Out-File $FullLogPath -Append
					"$Date" | Out-File $FullLogPath -Append
					$ErrorsHappened = $True

					Write-Verbose "Build custom object properties."
					$Properties = @{
											Status = "Failed to find $ADGroup"
											Username = "$SamAccountName"
											Name = "$Member"
											Group = "null"}
				}
			}
            Catch {

				Write-Verbose "$User was not found." 
				Write-Verbose "Appending error log."
				"$User was not found." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
				$ErrorsHappened = $True

				Write-Verbose "Build custom object properties."
                $Properties = @{
										Status = "Failed to find $User"
										Username = "null"
										Name = "null"
										Group = "null"}  
			}
            Finally{

				Write-Verbose "Create new custom object." 
				$Object = New-Object -TypeName 'PSObject' -Property $Properties  
				Write-Verbose "Display custom object." 
				Write-Output $Object 
            }
		}
    }
    END {
                                
		if($ErrorsHappened) { 

			Write-verbose "Error has been logged to $FullLogPath."
		}
    }
}


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
    
		Write-verbose "Testing if error path exists."
		$PathBool = Test-Path -Path $ErrorLogFilePath | Out-Null
		$Date = Get-Date | Out-Null

		if ($PathBool = 'False') {
        
            Write-Verbose "Creating $ErrorLogFilePath."
            New-Item -Path "$ErrorLogFilePath\Copy-ADGroupMember.txt" -ItemType File -Force | Out-Null
            Write-Verbose "Error log path created."
        }
    }
    PROCESS {

        Write-Host "Adding the following groups to $To" -ForegroundColor Green 

            Try {
                    
                #Get the From User's groups.
                $FromUsername = Get-ADUser $From -Properties * -ErrorAction Stop

                Try { 
                        
                    #Get the To User.
                    $ToUsername = Get-ADUser $To -Properties * -ErrorAction Stop
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


$BackUpLog = "C:\PoSH\ADGroupMember\BackupLogs"

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
    
		Write-verbose "Testing if error path exists."
		$PathBool = Test-Path -Path $ErrorLogFilePath | Out-Null
		$Date = Get-Date | Out-Null

		if ($PathBool = 'False') {
        
            Write-Verbose "Creating $ErrorLogFilePath."
            New-Item -Path "$ErrorLogFilePath\Remove-BUSINESSADGroupMember.txt" -ItemType File -Force | Out-Null
            Write-Verbose "Error log path created."
        }
    }
    PROCESS {
        Try {
                    
			#Get the From User's groups.
			$ADUsername = Get-ADUser "$Username" -Properties * -ErrorAction Stop
			$SamAccountName = $ADuser.SamAccountName
			$MemberOf = $ADUser.MemberOf
			$ErrorsHappened = "$FALSE"
                                
            Try {
                        
                #Backup the Users Groups to file path.
                Foreach ($Group in $MemberOf) {

                    $Group | Out-File $BackUpLog -Append -ErrorAction stop 
                    $ErrorsHappened = "$FALSE"
                }

		        Write-Host "$SamAccountName's groups backed up to $BackUpLog" -ForegroundColor Green
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