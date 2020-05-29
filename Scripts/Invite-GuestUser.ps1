#Requires –Modules AzureAD

$Guests = @{ 
    "Display Name" = "fname.lname@domain.com"
    "fName lName"  = "fName.lName@otherdomain.com"
}

foreach ($G in $Guests.GetEnumerator()) {    
    New-AzureADMSInvitation `
        -InvitedUserDisplayName $G.name `
        -InvitedUserEmailAddress $G.value `
        -InviteRedirectURL https://myapplications.microsoft.com/ `
        -SendInvitationMessage $true
}
