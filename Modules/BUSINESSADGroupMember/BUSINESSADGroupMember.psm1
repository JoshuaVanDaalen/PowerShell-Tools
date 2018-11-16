$LogPreference = "C:\PoSH\BUSINESSADGroupMember"
Function Get-BUSINESSADGroupMember {

    <#
    .Synopsis
	    Get all groups each user is a member of.

    .DESCRIPTION
        The Get-BUSINESSADGroupMember function accepts an array of usernames and returns all group memberships.        

    .EXAMPLE
        Get-BUSINESSADGroupMember -Username 'UserX'

    .EXAMPLE
		Get-BUSINESSADGroupMember -Username 'UserX','UserY','UserZ'
    
	.NOTES		
		You need to have the Active Directory module to use this function.

	.LINK
		https://github.com/greenSacrifice/WindowsPowerShell/tree/master/Modules
#>

    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $True,
            HelpMessage = "Enter Username")] 
        [String[]]
        $Username,

        [Parameter()]
        [String]
        $ErrorLogFilePath = $LogPreference)

    BEGIN {
    
        Write-Verbose "Testing if error path exists."
        $FullLogPath = "$ErrorLogFilePath\Get-ADGroupMember.txt"
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

        Write-Verbose "Iterating each user."
        Foreach ($User in $Username) {
            
            Try {                      
                 
                Write-Verbose "Locating $User."
                $ADUser = Get-ADUser -Identity "$User" -Properties 'MemberOf' -ErrorAction 'Stop'
                $DisplayName = $ADUser.Name
                $SamAccountName = $ADUser.SamAccountName
                $MemberOf = $ADUser.MemberOf
                $GroupCount = $MemberOf.Count
                $ErrorsHappened = $false
                Write-Verbose "Successful, $DisplayName located."
                Write-Verbose "$DisplayName has $GroupCount groups."
                Write-Verbose "Name of each group:"                
            }
            Catch {

                Write-Verbose "$User was not found."
                Write-Verbose "Appending error log."
                "$User was not found." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
                $ErrorsHappened = $True

                Write-Verbose "Build custom object properties."
                $Properties = @{
                    'Canonical Name' = ''
                    'Group Mail'     = ''
                    'Group Name'     = ''
                    'Username'       = "Failed to find $User"
                }
            }
            Finally {
                if ($ErrorsHappened -eq $false) { 
                    Foreach ($DistinguishedName in $MemberOf) {

                        $Group = Get-ADGroup $DistinguishedName -Properties 'Name', 'Mail', 'CanonicalName'
                        $GroupName = $Group.Name
                        $GroupMail = $Group.Mail
                        $CanonicalName = $Group.CanonicalName
      
                        if ($GroupMail.length -lt 1) {
                            $GroupMail = 'Null'
                        }
                
                        $Properties = @{
                            'Canonical Name' = $CanonicalName
                            'Group Mail'     = $GroupMail
                            'Group Name'     = $GroupName
                            'Username'       = $SamAccountName
                        }
                        Write-Verbose "Displaying custom object properties."
                        $PSObject = New-Object -TypeName PSObject -Property $Properties
                        Write-Output $PSObject 
                    }
                }
                elseif ($ErrorsHappened -eq $True) {
                    Write-Verbose "Displaying error object properties."
                    $PSObject = New-Object -TypeName PSObject -Property $Properties
                    Write-Output $PSObject 
                }
                              
            }
        }
    }
    END {

        if ($ErrorsHappened) { 
            Write-verbose "Error has been logged to $FullLogPath."
        }
    }
}

Function Add-BUSINESSADGroupMember {

    <#
    .Synopsis
	    Add a user to a Active Directory group.

    .DESCRIPTION
		The Add-BUSINESSADGroupMember function accepts an array of usernames that will be added to the Active Directory Group you choose.

    .EXAMPLE
        Add-BUSINESSADGroupMember -Username 'UserX' -ADGroup "GroupY"

    .EXAMPLE
		Add-BUSINESSADGroupMember -Username 'UserX','UserY','UserZ' -ADGroup "GroupY"
    
	.NOTES
		You need to have the Exchange module to use this function.
		You need to have the Active Directory module to use this function.

	.LINK
		https://github.com/greenSacrifice/WindowsPowerShell/blob/master/Modules/
#>

    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $True,
            HelpMessage = "Enter Username")] 
        [String[]]
        $Username,
            
        [Parameter(Mandatory = $True,
            HelpMessage = "Enter Distibution Group")] 
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

        Write-Verbose "Iterating each user."
        Foreach ($User in $Username) {
            
            Try {                      
                 
                Write-Verbose "Locating $User."
                $ADUser = Get-ADUser -Identity "$User" -Properties 'mail' -ErrorAction 'Stop'
                $Member = $ADUser.Name
                $SamAccountName = $ADUser.SamAccountName 
                Write-Verbose "Successful, $Member located."

                Try {
					
                    Write-Verbose "Testing if $ADGroup."
                    $Group = Get-ADGroup -Identity "$ADGroup" -ErrorAction 'Stop'
                    $Identity = $Group.SamAccountName
                    Write-Verbose "Successful, $Identity located."

                    Try {

                        Write-Verbose "Collecting Parameters."
                        $Parameters = @{
                            'Identity'       = $Identity
                            'SamAccountName' = $SamAccountName
                            'ErrorAction'    = 'Stop'
                        }

                        Write-Verbose "Splatting parameters to Cmdlet."
                        $Session = Add-ADGroupMember @Parameters
                        Write-Verbose "Cmdlet successful."

                        Write-Verbose "Build custom object properties."
                        $Properties = @{
                            'Status'   = "Member added"
                            'Username' = $SamAccountName
                            'Name'     = $Member
                            'Group'    = $Identity
                        }
                    }
                    Catch {
                        
                        Write-Verbose "Failed to add $Member to $Identity."
                        Write-Verbose "Appending error log."
                        "$Member was not added to $Identity." | Out-File $FullLogPath -Append
                        "$Date" | Out-File $FullLogPath -Append
                        $ErrorsHappened = $True

                        Write-Verbose "Build custom object properties."
                        $Properties = @{
                            Status   = "Failed to add $SamAccountName"
                            Username = "$SamAccountName"
                            Name     = "$Member"
                            Group    = "$Identity"
                        }
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
                        Status   = "Failed to find $ADGroup"
                        Username = "$SamAccountName"
                        Name     = "$Member"
                        Group    = "Null"
                    }
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
                    Status   = "Failed to find $User"
                    Username = "Null"
                    Name     = "Null"
                    Group    = "Null"
                }  
            }
            Finally {

                Write-Verbose "Create new custom object." 
                $Object = New-Object -TypeName 'PSObject' -Property $Properties  
                Write-Verbose "Display custom object." 
                Write-Output $Object 
            }
        }
    }
    END {
                                
        if ($ErrorsHappened) { 

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

	.LINK
		https://github.com/greenSacrifice/WindowsPowerShell/blob/master/Modules/
#>

    [cmdletBinding()]
    param(        
        [Parameter(Mandatory = $True,
            HelpMessage = "Username that has groups you want to copy?")] 
        [String]
        $From,

        [Parameter(Mandatory = $True,
            HelpMessage = "What User is recieving these Groups?")] 
        [String]
        $To,

        [Parameter()]
        [String]
        $ErrorLogFilePath = $LogPreference)

    BEGIN {
    
        Write-Verbose "Testing if error path exists."
        $FullLogPath = "$ErrorLogFilePath\Copy-ADGroupMember.txt"
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
        #Write-Host "Adding the following groups to $To" -ForegroundColor Green 

        Try {

            Write-Verbose "Locating $From."
            $FromUser = Get-ADUser $From -Properties 'MemberOf' -ErrorAction 'Stop'
            $FromName = $FromUser.Name
            $FromGroups = $FromUser.MemberOf
            Write-Verbose "Successful, $FromName located."

            Try {

                Write-Verbose "Locating $To."
                $ToUser = Get-ADUser $To -Properties 'MemberOf' -ErrorAction 'Stop'
                $ToName = $ToUser.Name
                $ToSamAccountName = $ToUser.SamAccountName
                Write-Verbose "Successfully $ToName located."

                Try {

                    Write-Verbose "Iterating each group."
                    Foreach ($Group in $FromGroups) {
                        
                        $Pos = $Group.IndexOf(",")
                        $Trim = $Group.Substring(0, $Pos)

                        Write-Verbose "Collecting Parameters."
                        $Parameters = @{
                            'Identity'       = $Group
                            'SamAccountName' = $ToSamAccountName
                            'ErrorAction'    = 'Stop'
                        }
                        
                        Write-Verbose "Splatting parameters to Cmdlet."
                        $Session = Add-ADGroupMember @Parameters
                        Write-Verbose "Cmdlet successful."

                        #Write-Host "$Trim" -ForegroundColor Cyan

                        Write-Verbose "Build custom object properties."
                        $Properties = @{
                            'Status' = "Successful"
                            'From'   = $FromName
                            'To'     = $ToName
                            'Group'  = $Trim
                        }
                    }
                }
                Catch {
                        
                    Write-Verbose "Failed to add $Trim to $ToSamAccountName."
                    Write-Verbose "Appending error log."
                    "$FromGroups was not added to $ToSamAccountName." | Out-File $FullLogPath -Append
                    "$Date" | Out-File $FullLogPath -Append
                    $ErrorsHappened = $True

                    #Write-Host "Failed to Add $Group to $To." -ForegroundColor Red
                    
                    Write-Verbose "Build custom object properties."
                    $Properties = @{
                        'Status' = "Failed."
                        'From'   = $FromName
                        'To'     = $ToName
                        'Group'  = $Trim
                    }
                }                 
            }
            Catch {
                     
                Write-Verbose "$To was not found."
                Write-Verbose "Appending error log."
                "$To was not found." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
                $ErrorsHappened = $True

                #Write-Host "Failed to find $To." -ForegroundColor Red

                Write-Verbose "Build custom object properties."
                $Properties = @{
                    'Status' = "Missing User."
                    'From'   = $FromName
                    'To'     = $To
                    'Group'  = 'Null'
                }
            }
        }
        Catch {                                      

            Write-Verbose "$From was not found."
            Write-Verbose "Appending error log."
            "$From was not found." | Out-File $FullLogPath -Append
            "$Date" | Out-File $FullLogPath -Append
            $ErrorsHappened = $True

            #Write-Host "Failed to find $From." -ForegroundColor Red

            Write-Verbose "Build custom object properties."
            $Properties = @{
                'Status' = "Missing User."
                'From'   = $From
                'To'     = 'Null'
                'Group'  = 'Null'
            }
        }            
        Finally {

            Write-Verbose "Displaying custom object properties."
            $obj = New-Object -TypeName PSObject -Property $Properties
            Write-Output $obj  
        }
    }
    END {
        if ($ErrorsHappened) {

            Write-verbose "Error has been logged to $ErrorLogFilePath."

        }
    }
}

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
    
    .LINK
		https://github.com/greenSacrifice/WindowsPowerShell/blob/master/Modules/
#>

    [cmdletBinding()]
    param(
        #Path that contains the CSV file.
        [Parameter(Mandatory = $True,
            HelpMessage = "Who's groups do you want to copy?")] 
        [String[]]
        $Username,        

        #Creates an Object for the error path variable.
        [Parameter()]
        [String]
        $ErrorLogFilePath = $LogPreference)
    BEGIN {
    
        Write-Verbose "Testing if error path exists."
        $FullLogPath = "$ErrorLogFilePath\Remove-ADGroupMember.txt"
        $BackUpLog = "$ErrorLogFilePath\GroupsFrom$Username.txt"
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
        #Foreach user block goes here.
        Try {

            Write-Verbose "Locating $Username."
            $ADUser = Get-ADUser "$Username" -Properties * -ErrorAction Stop
            $MemberOf = $ADUser.MemberOf
            $SamAccountName = $ADUser.SamAccountName
            $ErrorsHappened = "$false"
            Write-Verbose "Successful, $SamAccountName located."
                                
            Try {   

                Write-Verbose "Iterating each group."                     
                Foreach ($Group in $MemberOf) {

                    Write-Verbose "Backing up group to backuplog."
                    $Group | Out-File $BackUpLog -Append -ErrorAction stop 
                    $ErrorsHappened = "$false"
                }

                #Write-Host "$SamAccountName's groups backed up to $BackUpLog" -ForegroundColor Green
                #Write-Host "Removing the following groups from $SamAccountName" -ForegroundColor Green 

                Try {

                    $Pos = $Group.IndexOf(",")
                    $Trim = $Group.Substring(0, $Pos)

                    Write-Verbose "Collecting Parameters."
                    $Parameters = @{
                        'Identity'       = $Group
                        'SamAccountName' = $SamAccountName
                        'ErrorAction'    = 'Stop'
                    }
                    
                    Write-Verbose "Splatting parameters to Cmdlet."
                    Remove-ADGroupMember @Parameters -Confirm:$False
                    Write-Verbose "Cmdlet successful."

                    #Write-Host "$Trim" -ForegroundColor Cyan

                    Write-Verbose "Build custom object properties."
                    $Properties = @{
                        'Status'   = "Successful"
                        'Username' = $SamAccountName
                        'BackUp'   = "Successful"
                        'Group'    = $Trim
                    }
                }
                Catch {
                    
                    Write-Verbose "Failed to remove $Trim to $SamAccountName."
                    Write-Verbose "Appending error log."
                    "$Trim was not remove from $SamAccountName." | Out-File $FullLogPath -Append
                    "$Date" | Out-File $FullLogPath -Append
                    $ErrorsHappened = $True
                    
                    #Write-Host "Failed to remove $SamAccountName's groups." -ForegroundColor Red

                    Write-Verbose "Build custom object properties."
                    $Properties = @{
                        'Status'   = "Failed"
                        'Username' = $SamAccountName
                        'BackUp'   = "Successful"
                        'Group'    = $Trim
                    }
                }
            }
            Catch {

                Write-Verbose "Failed to backup $Trim."
                Write-Verbose "Appending error log."
                "$Trim was not backuped to $BackUpLog." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
                $ErrorsHappened = $True
                
                #Write-Host "Failed to backup $SamAccountName's groups." -ForegroundColor Red

                Write-Verbose "Build custom object properties."
                $Properties = @{
                    'Status'   = "Failed"
                    'Username' = $SamAccountName
                    'BackUp'   = "Failed"
                    'Group'    = $Trim
                }
            }
        }
        Catch {

            Write-Verbose "$Username was not found.."
            Write-Verbose "Appending error log."
            "$Username was not found." | Out-File $FullLogPath -Append
            "$Date" | Out-File $FullLogPath -Append
            $ErrorsHappened = $True

            #Write-Host "Failed to find $Username." -ForegroundColor Red

            Write-Verbose "Build custom object properties."
            $Properties = @{
                'Status'   = "Missing User"
                'Username' = $Username
                'BackUp'   = "Failed"
                'Group'    = $Trim
            }
        }
        Finally {

            Write-Verbose "Displaying custom object properties."
            $obj = New-Object -TypeName PSObject -Property $Properties
            Write-Output $obj  
        }
    }
    END {
        if ($ErrorsHappened) {

            Write-verbose "Error has been logged to $ErrorLogFilePath."
        }
    }
}

#Written by Joshua Van Daalen.