#Requires –Modules AzureAD

$GuestList = @{ 
    "Display Name" = "fname.lname@domain.com"
    "fName lName"  = "fName.lName@otherdomain.com"
}

foreach ($guest in $GuestList.GetEnumerator()) {    
    New-AzureADMSInvitation `
        -InvitedUserDisplayName $guest.name `
        -InvitedUserEmailAddress $guest.value `
        -InviteRedirectURL https://myapplications.microsoft.com/ `
        -SendInvitationMessage $true
}
