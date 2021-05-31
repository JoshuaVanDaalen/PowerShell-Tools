

Connect-ExchangeOnline -UserPrincipalName 'joshua@domain.com.au' -ShowProgress $true -ShowBanner:$false
Connect-AzureAD

$ADUsers = Get-AzureADUser -All $true -Filter "userType eq 'Member'" | Where-Object { $_.AccountEnabled -eq $true }
# $Mailboxes = Get-Mailbox -ResultSize Unlimited

$gName = ''
$gEmail = ''
{
    "fromDate": "2018-08-01",
    "toDate": "2019-11-18",
    "Format": "Json",
    "periodType": "Monthly",
    "UserId": "person.name@gmail.com",
    "AccountId": "2018050759"
}

$UPN = 'person.name@domain-old.com.au'

foreach ($user in $ADUsers) {
    if ($user.UserPrincipalName -eq $UPN) {
        $aliases = (get-mailbox -Identity $user.UserPrincipalName).EmailAddresses
        $aliases
        for ($i = 0; $i -lt $aliases.Count; $i++) {
                
            $a = $aliases[$i]

            if ($a.Substring(0, 4) -ceq 'SMTP') {
                $aliases[$i] = $a.ToLower()
            }
            if ($a.Contains('domain')) {
                $aliases[$i] = $a.replace("smtp", "SMTP")
                $newUserPrincipalName = $a.replace("smtp:", "")
            }
        }
        $gEmail = $newUserPrincipalName
        $gName = $gemail.Substring(0, $gemail.IndexOf('@')) 
        $newUserPrincipalName
        $gName
        # Set-Mailbox -Identity $user.UserPrincipalName -EmailAddresses $aliases
        # Set-AzureADUser -ObjectID $user.ObjectId -UserPrincipalName $newUserPrincipalName
    }
}

Connect-ExchangeOnline -UserPrincipalName 'josh@domain-old.com.au' -ShowProgress $true -ShowBanner:$false

# Set-Mailbox -Identity "person.name" -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "person.name@domain.com.au"



$UPN = 'person.name@domain.com.au'
$shortName = $UPN.Substring(0, $UPN.IndexOf('@')) 

# New-MailContact -Name $UPN -ExternalEmailAddress $UPN
# Set-Mailbox -Identity $shortName -DeliverToMailboxAndForward $true -ForwardingAddress $UPN  -ForwardingSMTPAddress$UPN 
Set-Mailbox -Identity $shortName -DeliverToMailboxAndForward $true -ForwardingSMTPAddress $UPN 
get-mailbox -Identity $shortName | Select-Object UserPrincipalName, forward*

