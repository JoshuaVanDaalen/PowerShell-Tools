$LogPreference = "C:\PoSH Logs\BUSINESSExportPST\New-BUSINESSExportPST.txt"

#TODO: Update help
#TODO: File path should = rootdrive?

function New-BUSINESSExportPST{
<#
    .SYNOPSIS

    Export Users Outlook Data File.

    .DESCRIPTION

    Quick way the Export the Outlook Data File for a user. You can find the Exported file at C:\MailboxExport\

    .EXAMPLE

    New-BUSINESSExportPST 

    .EXAMPLE

    New-BUSINESSExportPST -Username "UserX"

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
                HelpMessage="Enter The Username.")] 
                [String[]]
                $Username,
                
    [Parameter()]
                [String]
                $ErrorLogFilePath = $LogPreference)
                   
    BEGIN{   
            
        Remove-Item -Path $ErrorLogFilePath -Force -ErrorAction SilentlyContinue
        $ErrorsHappened = $false
		$FilePath = "\\FILESERVER\MailboxExport"
                                    
    }         
    PROCESS {

        Foreach ($User in $Username) {
                
            #Retrive Active Directory User.
            Try {
                
                Write-Host "Searching for $User."-ForegroundColor 'green'
                $ADUser = Get-ADUser $User -Properties Mail -ErrorAction 'silentlycontinue'
                $SamAccountName = $ADUser.SamAccountName

                #Export Outlook Data File.
                Try {
                    
                    $ExportPath = "$FilePath\$SamAccountName.pst"
                    $Export = New-MailboxExportRequest -Mailbox $SamAccountName -FilePath $FilePath -ErrorAction 'Stop'
                    
                    $Properties = @{Status = "Export in progress."
                                    Username = $SamAccountName
                                    Name = $ADUser.Name
                                    Email = $ADUser.Mail}
                }
                Catch {
                    
                    $ErrorsHappened = $True
                    Write-Host "Failed to Export $SamAccountName's Mailbox." -ForegroundColor 'red'
                    $SamAccountName | Out-File $ErrorLogFilePath -Append

                    $Properties = @{Status = "Failed to export."
                                    Username = $SamAccountName
                                    Name = $ADUser.Name
                                    Email = $ADUser.Mail}
                }
            }
            Catch {

                    $ErrorsHappened = $True
                    Write-Host "Couldn't find $User." -ForegroundColor 'red'
                    $User | Out-File $ErrorLogFilePath -Append

                    $Properties = @{Status = "Failed to find $user."
                                    Username = $NULL
                                    Name = $NULL
                                    Email = $NULL}                    
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