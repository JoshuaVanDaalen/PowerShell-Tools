$LogPreference = 'C:\PoSH\BUSINESSADGroupMember'
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
		https://github.com/greenSacrifice/PowerShell/
#>

    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $True,
            HelpMessage = 'Enter Username')] 
        [String[]]
        $Username,

        [Parameter()]
        [String]
        $ErrorLogFilePath = $LogPreference)

    BEGIN {
    
        Write-Verbose 'Testing if error path exists.'
        $FullLogPath = "$ErrorLogFilePath\Get-ADGroupMember.txt"
        $PathBool = Test-Path -Path $FullLogPath
        $Date = Get-Date

        if ($PathBool) {

            Write-Verbose 'Log path exists.'
        }
        elseif ($PathBool = "$false") {

            Write-Verbose 'Creating error log directory.'
            New-Item -Path "$FullLogPath" -ItemType 'File' -Force | Out-Null
            Write-Verbose 'Error log directory created.'
        }
    }
    PROCESS {

        Write-Verbose 'Iterating each user.'
        Foreach ($User in $Username) {            
            Try {                      
                 
                Write-Verbose "Locating $User."
                $ADUserParameters = @{
                    'Identity'      = $User
                    'Properties'    = 'MemberOf'
                    'ErrorAction'   = 'Stop'
                    'ErrorVariable' = 'ADUserError'
                }
                $ADUser = Get-ADUser @ADUserParameters
                $DisplayName = $ADUser.Name
                $SamAccountName = $ADUser.SamAccountName
                $MemberOf = $ADUser.MemberOf
                $GroupCount = $MemberOf.Count
                $ErrorsHappened = "$false"
                Write-Verbose "Successful, $DisplayName located."
                Write-Verbose "$DisplayName has $GroupCount groups."
                Write-Verbose 'Name of each group:'
            }
            Catch {

                Write-Verbose "$User was not found."
                Write-Verbose 'Appending error log.'
                "$User was not found." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
                $ErrorsHappened = $True

                Write-Verbose 'Build custom object properties.'
                $Properties = @{
                    'CanonicalName' = ''
                    'GroupMail'     = ''
                    'GroupName'     = ''
                    'Username'      = "Failed to find $User"
                }
            }
            Finally {
                if ($ADUserError) {
                    Write-Verbose 'Displaying error object properties.'
                    $PSObject = New-Object -TypeName PSObject -Property $Properties
                    Write-Output $PSObject 
                }
                else { 
                    Foreach ($DistinguishedName in $MemberOf) {
                       
                        $Group = Get-ADGroup -Identity $DistinguishedName -Properties 'MemberOf', 'Mail', 'CanonicalName'
                        $GroupName = $Group.Name
                        $GroupMail = $Group.Mail
                        $CanonicalName = $Group.CanonicalName
                        Write-Verbose "$GroupName"
      
                        if ($GroupMail.length -lt 1) {
                            $GroupMail = 'Null'
                        }
                
                        $Properties = @{
                            'CanonicalName' = $CanonicalName
                            'GroupMail'     = $GroupMail
                            'GroupName'     = $GroupName
                            'Username'      = $SamAccountName
                        }
                        Write-Verbose 'Displaying custom object properties.'
                        $PSObject = New-Object -TypeName PSObject -Property $Properties
                        Write-Output $PSObject 
                    }
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
        Add-BUSINESSADGroupMember -Username 'UserX' -ADGroup 'GroupY'

    .EXAMPLE
		Add-BUSINESSADGroupMember -Username 'UserX','UserY','UserZ' -ADGroup 'GroupY'
    
	.NOTES
		You need to have the Exchange module to use this function.
		You need to have the Active Directory module to use this function.

	.LINK
		https://github.com/greenSacrifice/PowerShell/
#>

    [cmdletBinding()]
    param(
        [Parameter(Mandatory = $True,
            HelpMessage = 'Enter Username')] 
        [String[]]
        $Username,
            
        [Parameter(Mandatory = $True,
            HelpMessage = 'Enter Distibution Group')] 
        [String]
        $ADGroup,

        [Parameter()]
        [String]
        $ErrorLogFilePath = $LogPreference)

    BEGIN {
    
        Write-Verbose 'Testing if error path exists.'
        $FullLogPath = "$ErrorLogFilePath\Add-ADGroupMember.txt"
        $PathBool = Test-Path -Path $FullLogPath
        $Date = Get-Date

        if ($PathBool) {

            Write-Verbose 'Log path exists.'
        }
        elseif ($PathBool = "$false") {

            Write-Verbose 'Creating error log directory.'
            New-Item -Path "$FullLogPath" -ItemType 'File' -Force | Out-Null
            Write-Verbose 'Error log directory created.'
        }
    }
    PROCESS {

        Write-Verbose 'Iterating each user.'
        Foreach ($User in $Username) {
            
            Try {
                
                Write-Verbose "Locating $User."
                $UserParameters = @{
                    'Identity'      = $User
                    'ErrorAction'   = 'Stop'
                    'ErrorVariable' = 'UserError'
                }
    
                $ADUser = Get-ADUser @UserParameters
                $ADUserName = $ADUser.Name
                $UserSamAccountName = $ADUser.SamAccountName                 
                Write-Verbose "Successful, $Member located."

                Write-Verbose "Testing if $ADGroup."
                $GroupParameters = @{
                    'Identity'      = $ADGroup
                    'ErrorAction'   = 'Stop'
                    'ErrorVariable' = 'GroupError'
                }
                $Group = Get-ADGroup @GroupParameters
                $GroupSamAccountName = $Group.SamAccountName
                Write-Verbose "Successful, $GroupSamAccountName located."

                Write-Verbose 'Collecting Parameters.'
                $Parameters = @{
                    'Identity'      = $GroupSamAccountName
                    'Members'       = $UserSamAccountName
                    'ErrorAction'   = 'Stop'
                    'ErrorVariable' = 'AddGroupError'

                }

                Write-Verbose 'Splatting parameters.'
                $Session = Add-ADGroupMember @Parameters
                Write-Verbose 'Successful.'
                $Status = 'Member added'
            }           
         
            Catch {
                if ($UserError) {
                    Write-Verbose "$User was not found." 
                    Write-Verbose 'Appending error log.'
                    "$User was not found." | Out-File $FullLogPath -Append
                    "$Date" | Out-File $FullLogPath -Append
                    $Status = "Failed to find $User"                            
                    $ADUserName = ''
                    $UserSamAccountName = ''

                }
                elseif ($GroupError) {
                    Write-Verbose "$ADGroup was not found."
                    Write-Verbose 'Appending error log.'
                    "$ADGroup was not found." | Out-File $FullLogPath -Append
                    "$Date" | Out-File $FullLogPath -Append
                    $Status = "Failed to find $ADGroup"
                    $GroupSamAccountName = ''
                }
                elseif ($AddGroupError) {
                    Write-Verbose "Failed to add $ADUserName to $GroupSamAccountName."
                    Write-Verbose 'Appending error log.'
                    "$ADUserName was not added to $GroupSamAccountName." | Out-File $FullLogPath -Append
                    "$Date" | Out-File $FullLogPath -Append
                    $Status = "Failed adding $UserSamAccountName to $GroupSamAccountName"

                }
                $ErrorsHappened = $True
            }
            
            Finally {
                
                Write-Verbose 'Build custom object properties.'
                $Properties = @{
                    'Status'   = $Status
                    'Username' = $UserSamAccountName
                    'Name'     = $ADUserName
                    'Group'    = $GroupSamAccountName
                }

                Write-Verbose 'Create new custom object.' 
                $PSObject = New-Object -TypeName PSObject -Property $Properties  
                Write-Verbose 'Display custom object.' 
                Write-Output $PSObject 
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
		https://github.com/greenSacrifice/PowerShell/
    #>
    [cmdletBinding()]
    param(        
        [Parameter(Mandatory = $True,
            HelpMessage = 'Username that has groups you want to copy?')] 
        [String]
        $From,

        [Parameter(Mandatory = $True,
            HelpMessage = 'What User is recieving these Groups?')] 
        [String]
        $To,

        [Parameter()]
        [String]
        $ErrorLogFilePath = $LogPreference)
    BEGIN {
    
        Write-Verbose 'Testing if error path exists.'
        $FullLogPath = "$ErrorLogFilePath\Copy-ADGroupMember.txt"
        $PathBool = Test-Path -Path $FullLogPath
        $Date = Get-Date
        $ErrorsHappened = $false

        if ($PathBool) {

            Write-Verbose 'Log path exists.'
        }
        elseif ($PathBool = "$false") {

            Write-Verbose 'Creating error log directory.'
            New-Item -Path "$FullLogPath" -ItemType 'File' -Force | Out-Null
            Write-Verbose 'Error log directory created.'
        }
    }    
    PROCESS {        
        Try {

            Write-Verbose "Locating $From."            
            $FromUserParameters = @{
                'Identity'      = $From
                'Properties'    = 'MemberOf'
                'ErrorAction'   = 'Stop'
                'ErrorVariable' = 'FromError'
            }

            $FromUser = Get-ADUser @FromUserParameters
            $FromName = $FromUser.Name
            $FromGroups = $FromUser.MemberOf            
            Write-Verbose "Successful, $FromName located."

            Write-Verbose "Locating $To."
            $ToUserParameters = @{
                'Identity'      = $To
                'Properties'    = 'MemberOf'
                'ErrorAction'   = 'Stop'
                'ErrorVariable' = 'ToError'
            }

            $ToUser = Get-ADUser @ToUserParameters
            $ToName = $ToUser.Name
            $ToSamAccountName = $ToUser.SamAccountName
            Write-Verbose "Successfully $ToName located."
        }
        Catch {
            if ($FromError) {
                Write-Verbose "$From was not found."
                Write-Verbose 'Appending error log.'
                "$From was not found." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
                $FromName = 'NULL'
            }
            elseif ($ToError) {
                Write-Verbose "$To was not found."
                Write-Verbose 'Appending error log.'
                "$To was not found." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
            }
            else {
                Write-Verbose 'Unknown error.'
            }
            $ErrorsHappened = $True
            Write-Verbose 'Building error object properties.'
            $Properties = @{
                'Status' = 'Missing User'
                'From'   = $FromName
                'To'     = 'NULL'
                'Group'  = ''
            }           
        }

        Finally {            
            if ($ErrorsHappened) {
                Write-Verbose 'Displaying error object properties.'
                $PSObject = New-Object -TypeName PSObject -Property $Properties
                Write-Output $PSObject
            }
            else {

                Foreach ($Group in $FromGroups) {
                    Try {                    
    
                        $ADGroup = Get-ADGroup $Group
                        $ADGroupName = $ADGroup.Name
        
                        $GroupParameters = @{
                            'Identity'      = $ADGroupName
                            'Member'        = $ToSamAccountName
                            'ErrorAction'   = 'Stop'
                            'ErrorVariable' = 'GroupError'
                        }
        
                        Write-Verbose "Attempting to add $ADGroupName"
                        Add-ADGroupMember @GroupParameters
                        $Status = 'Successful'
                    }        
                    Catch {
                        if ($GroupError) {
                            Write-Verbose "Failed to add $ADGroupName to $ToName."
                            Write-Verbose 'Appending error log.'
                            "$ADGroupName was not added to $ToName." | Out-File $FullLogPath -Append
                            "$Date" | Out-File $FullLogPath -Append
                            $ErrorsHappened = $True
                            $Status = 'Failed'
                        }
                    }
                    Write-Verbose 'Build custom object properties.'
                    $Properties = @{
                        'Status' = $Status
                        'From'   = $FromName
                        'To'     = $ToName
                        'Group'  = $ADGroupName
                    }
                    Write-Verbose 'Building custom object properties.'
                    $PSObject = New-Object -TypeName PSObject -Property $Properties
                    Write-Output $PSObject
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
		https://github.com/greenSacrifice/PowerShell/
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
    
        Write-Verbose 'Testing if error path exists.'
        $FullLogPath = "$ErrorLogFilePath\Remove-ADGroupMember.txt"
        $BackUpLog = "$ErrorLogFilePath\GroupsFrom$Username.txt"
        $PathBool = Test-Path -Path $FullLogPath
        $Date = Get-Date

        if ($PathBool) {

            Write-Verbose 'Log path exists.'
        }
        elseif ($PathBool = "$false") {

            Write-Verbose 'Creating error log directory.'
            New-Item -Path "$FullLogPath" -ItemType 'File' -Force | Out-Null
            Write-Verbose 'Error log directory created.'
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

                Write-Verbose 'Iterating each group.'                     
                Foreach ($Group in $MemberOf) {

                    Write-Verbose 'Backing up group to backuplog.'
                    $Group | Out-File $BackUpLog -Append -ErrorAction stop 
                    $ErrorsHappened = "$false"
                }

                #Write-Host "$SamAccountName's groups backed up to $BackUpLog" -ForegroundColor Green
                #Write-Host "Removing the following groups from $SamAccountName" -ForegroundColor Green 

                Try {

                    $Pos = $Group.IndexOf(',')
                    $Trim = $Group.Substring(0, $Pos)

                    Write-Verbose 'Collecting Parameters.'
                    $Parameters = @{
                        'Identity'       = $Group
                        'SamAccountName' = $SamAccountName
                        'ErrorAction'    = 'Stop'
                    }
                    
                    Write-Verbose 'Splatting parameters to Cmdlet.'
                    Remove-ADGroupMember @Parameters -Confirm:"$false"
                    Write-Verbose 'Cmdlet successful.'

                    #Write-Host "$Trim" -ForegroundColor Cyan

                    Write-Verbose 'Build custom object properties.'
                    $Properties = @{
                        'Status'   = 'Successful'
                        'Username' = $SamAccountName
                        'BackUp'   = 'Successful'
                        'Group'    = $Trim
                    }
                }
                Catch {
                    
                    Write-Verbose "Failed to remove $Trim to $SamAccountName."
                    Write-Verbose 'Appending error log.'
                    "$Trim was not remove from $SamAccountName." | Out-File $FullLogPath -Append
                    "$Date" | Out-File $FullLogPath -Append
                    $ErrorsHappened = $True
                    
                    #Write-Host "Failed to remove $SamAccountName's groups." -ForegroundColor Red

                    Write-Verbose 'Build custom object properties.'
                    $Properties = @{
                        'Status'   = 'Failed'
                        'Username' = $SamAccountName
                        'BackUp'   = 'Successful'
                        'Group'    = $Trim
                    }
                }
            }
            Catch {

                Write-Verbose "Failed to backup $Trim."
                Write-Verbose 'Appending error log.'
                "$Trim was not backuped to $BackUpLog." | Out-File $FullLogPath -Append
                "$Date" | Out-File $FullLogPath -Append
                $ErrorsHappened = $True
                
                #Write-Host "Failed to backup $SamAccountName's groups." -ForegroundColor Red

                Write-Verbose 'Build custom object properties.'
                $Properties = @{
                    'Status'   = 'Failed'
                    'Username' = $SamAccountName
                    'BackUp'   = 'Failed'
                    'Group'    = $Trim
                }
            }
        }
        Catch {

            Write-Verbose "$Username was not found.."
            Write-Verbose 'Appending error log.'
            "$Username was not found." | Out-File $FullLogPath -Append
            "$Date" | Out-File $FullLogPath -Append
            $ErrorsHappened = $True

            #Write-Host "Failed to find $Username." -ForegroundColor Red

            Write-Verbose 'Build custom object properties.'
            $Properties = @{
                'Status'   = 'Missing User'
                'Username' = $Username
                'BackUp'   = 'Failed'
                'Group'    = $Trim
            }
        }
        Finally {

            Write-Verbose 'Displaying custom object properties.'
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