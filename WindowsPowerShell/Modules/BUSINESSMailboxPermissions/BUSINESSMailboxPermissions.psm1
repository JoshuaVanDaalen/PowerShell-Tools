#Written by Joshua Van Daalen.

#TODO: Use splatting for readability
#TODO: Update help

function Add-BUSINESSMailboxPermissions {
  <#
    .SYNOPSIS

    Grant full Mailbox permissions to User.

    .DESCRIPTION

    Enter the Username of the User you will to give access to, followed by the Mailbox they require access to.

    .EXAMPLE

    Add-BUSINESSMailboxPermissions -Username 'UserX' -AccessTo 'UserY'

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
		https://github.com/greenSacrifice/PowerShell/
#>

  [cmdletBinding()]
  param(

    [Parameter(Mandatory = $True, HelpMessage = "Enter The Username of the User requesting access.")]
    [String]
    $Username,

    [Parameter(Mandatory = $True, HelpMessage = "Enter The Username of the Mailbox.")]
    [String]
    $Mailbox,

    [Parameter(Mandatory = $False, HelpMessage = "Should the user be able to send as the mailbox?.")]
    [Bool]
    $SendAs = $False

  )

  BEGIN {

    Connect-ExchangeOnline -UserPrincipalName 'joshua.vandaalen@BUSINESS.com.au' -ShowProgress $true -ShowBanner:$false -ErrorAction 'SilentlyContinue'

  }
  PROCESS {
    Try {

      Write-Verbose "Granting $Username Full Mailbox Access to $Mailbox."

      $Properties = @{
        'Status'     = 'Unknown'
        'FullAccess' = 'Unknown'
        'SendAs'     = 'Unknown'
        'Username'   = $Username
        'Mailbox'    = $Mailbox
      }

      Add-MailboxPermission `
        -Identity $Mailbox `
        -User $Username `
        -AccessRights 'FullAccess' `
        -InheritanceType 'All' `
        -ErrorAction 'Stop' | Out-Null

      $Properties.Status = 'Partial Update'
      $Properties.FullAccess = 'Granted'

      if ($SendAs) {

        Add-RecipientPermission `
          -Identity $Mailbox `
          -AccessRights 'SendAs' `
          -Trustee $Username  `
          -Confirm:$false `
          -ErrorAction 'Stop' | Out-Null

        $Properties.SendAs = 'Granted'

      }

      $Properties.Status = 'Successful'

    }
    Catch {}
    Finally {

      $obj = New-Object -TypeName PSObject -Property $Properties
      Write-Output $obj

    }
  }
  END {}
}
