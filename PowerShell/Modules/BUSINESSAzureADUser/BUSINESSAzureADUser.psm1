#Written by Joshua Van Daalen.
Function New-BUSINESSAzureADUser {
    <#
    .SYNOPSIS
    Create a new Azure AD User.

    .DESCRIPTION
    Running this function creates a Azure user account.
    The resulting user will have a email address firstname.lastname@BUSINESS.com.au
    Additionally the user is added to the all users group and the O365 licensing groups.

    .EXAMPLE
    New-BUSINESSADUser

    .EXAMPLE
    New-BUSINESSADUser -FirstName 'User' -LastName 'X'
#>

    [cmdletBinding()]
    param(

        [Parameter(Mandatory = $True, HelpMessage = "Enter the first name.")]
        [String]
        $FirstName,

        [Parameter(Mandatory = $True, HelpMessage = "Enter the last name.")]
        [String]
        $LastName,

        [Parameter(Mandatory = $False, HelpMessage = "Enter their job title.")]
        [String]
        $JobTitle
    )
    BEGIN {
        Add-Type -AssemblyName System.web;
        Connect-BUSINESSAzureAD
    }
    PROCESS {
        Try {

            $Properties = @{
                'Status'          = 'Unknown'
                'Username'        = 'Unknown'
                'DisplayName'     = 'Unknown'
                'P1License'       = 'Allocated'
                'BusinessPremium' = 'Unknown'
            }

            $licenses = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -like "*O365_BUSINESS_PREMIUM*" -or $_.SkuPartNumber -like "*AAD_PREMIUM*" }

            $o365BusinessPremium = $licenses.Where( { $_.SkuPartNumber -like "*O365_BUSINESS_PREMIUM" })
            $aAD_premium = $licenses.Where( { $_.SkuPartNumber -like "*AAD_PREMIUM" })

            if ($aAD_premium.PrepaidUnits.Enabled -le $aAD_premium.ConsumedUnits) {
                Write-Host -ForegroundColor Yellow "Order more ADP1 licenses from rhipe"
                $Properties.P1License = 'No licenses'
            }

            if ($o365BusinessPremium.PrepaidUnits.Enabled -le $o365BusinessPremium.ConsumedUnits) {
                Write-Host -ForegroundColor Yellow "Order more Business Premium licenses from rhipe"
            }

            if ($o365BusinessPremium.PrepaidUnits.Enabled -le $o365BusinessPremium.ConsumedUnits) {
                $Properties.BusinessPremium = 'No licenses'
                $Properties.Status = 'No license to allocate, increase Business Premium and try again'
            }
            else {

                $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
                $PasswordProfile.Password = [System.Web.Security.Membership]::GeneratePassword(16, 2)
                $tempPassword = "#$($LastName)12345678"
                $tempPasswordSecure = $tempPassword | ConvertTo-SecureString -AsPlainText -Force

                $Parameters = @{
                    DisplayName       = "$FirstName $LastName"
                    GivenName         = "$FirstName"
                    Surname           = "$LastName"
                    PasswordProfile   = $PasswordProfile
                    UserPrincipalName = "$FirstName.$LastName@BUSINESSgroup.com.au"
                    AccountEnabled    = $true
                    MailNickName      = "$FirstName$($LastName.Substring(0,1))"
                    ErrorAction       = 'Stop'
                }

                $NewUser = New-AzureADUser @Parameters

                $Properties.Username = $NewUser.UserPrincipalName
                $Properties.DisplayName = $NewUser.DisplayName
                $Properties.Status = 'User Created'
                $Properties.BusinessPremium = 'Allocated'

                Set-AzureADUserPassword -ObjectId $NewUser.ObjectId `
                    -Password $tempPasswordSecure `
                    -ForceChangePasswordNextLogin $true

                $Properties.Password = $tempPassword

                if ($JobTitle.Length -gt 0) {
                    Set-AzureADUser -ObjectId $NewUser.ObjectId `
                        -JobTitle $JobTitle
                }

                $Groups = Get-AzureADGroup -All $true |
                    Where-Object { $_.DisplayName -like 'License - Office 365 Business Premium' -OR $_.DisplayName -like 'License - Azure Premium P1' }

                $Groups.foreach( { Add-AzureADGroupMember `
                            -ObjectId  $_.ObjectId `
                            -RefObjectId $NewUser.ObjectId
                    })

                $Properties.Status = 'User Created Without All Users Group'

                Connect-ExchangeOnline -UserPrincipalName 'joshua.vandaalen@BUSINESSgroup.com.au' -ShowProgress $true -ShowBanner:$false

                while ((Get-DistributionGroupMember -Identity 'AllUsers@BUSINESSit.com.au' |
                            Where-Object { $_.PrimarySmtpAddress -eq $NewUser.UserPrincipalName }).PrimarySmtpAddress.Count -lt 1) {
                    Start-Sleep -Seconds 30
                    $session = Add-DistributionGroupMember -Identity 'AllUsers@BUSINESSit.com.au' -Member $NewUser.UserPrincipalName -ErrorAction SilentlyContinue
                }

                $Properties.Status = 'User Successfully Created'

                # $members = Get-DistributionGroupMember -Identity 'allusers@BUSINESSit.com.au'

                # $users = Get-AzADUser |
                # ? { $_.Type -eq 'Member' -and $_.AccountEnabled -eq 'False' `
                #         -and ($_.UserPrincipalName -notlike '*support*' -and $_.UserPrincipalName -notlike '*no-reply*' `
                #             -and $_.UserPrincipalName -notlike '*gridlogic*' -and $_.UserPrincipalName -notlike '*testuser*' `
                #             -and $_.UserPrincipalName -notlike '*meeting*' -and $_.UserPrincipalName -notlike '*scanto*'   `
                #             -and $_.UserPrincipalName -notlike '*nuos*' -and $_.UserPrincipalName -notlike '*system.a*' `
                #             -and $_.UserPrincipalName -notlike '*receipt*' -and $_.UserPrincipalName -notlike '*payment.auto*' `
                #             -and $_.UserPrincipalName -notlike '*mel@t*' -and $_.UserPrincipalName -notlike '*josh-tes*'     `
                #             -and $_.UserPrincipalName -notlike '*help@t*' -and $_.UserPrincipalName -notlike 'servicedesk*'     `
                #             -and $_.UserPrincipalName -notlike '*accounts@t*' -and $_.UserPrincipalName -notlike '*alerts@t*' `
                #             -and $_.UserPrincipalName -notlike '*svc_crm*' -and $_.UserPrincipalName -notlike '*BUSINESStestingmailbox@t*' `
                #             -and $_.UserPrincipalName -notlike '*development@*' -and $_.UserPrincipalName -notlike '*contact@*' `
                #             -and $_.UserPrincipalName -notlike 'OpsTeam*' -and $_.UserPrincipalName -notlike '*security*' `
                #             -and $_.UserPrincipalName -notlike '*carpark*'  -and $_.UserPrincipalName -notlike 'test.logic@*'
                #                        ) }

                # foreach ($u in $users) {
                #     $t = $members |
                #     ? { $_.PrimarySmtpAddress -eq $u }; if ($t) {}else {
                #         "Add-DistributionGroupMember -Identity 'AllUsers@BUSINESSit.com.au' -Member '$u' "
                #     }
                # }
            }
        }
        Catch {
            $Properties.Error = 'Errors Creating New User'
        }
        Finally {
            $obj = New-Object -TypeName PSObject -Property $Properties
            Write-Output $obj
        }
    }
    END {
    }
}
