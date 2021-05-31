function Set-BUSINESSAzContext {
    [cmdletBinding()]
    Param (
        [Parameter(HelpMessage = 'Select Env: Production, Non-Production, Sandbox?')]
        [ValidateSet('Prod', 'NonProd', 'Sandbox', 'Production', 'Non-Production', 'Sandbox')]
        [string]$Subscription = 'NonProd'
    )
    BEGIN {

        # Use the Subscription Id as the subscription name is subject to change.
        $SubscriptionID = @{
            'Prod'    = '35960155-d851-464e-8048-e20814098d13'
            'NonProd' = '18c45387-1352-4e50-8c3d-352f482222fb'
            'Sandbox' = 'b3c31edc-14aa-42fb-87f1-23f1d793b879'
        }

        $subscriptionList = Get-AzSubscription -WarningAction 'SilentlyContinue'

        if ($subscriptionList.Count -lt 1) {
            try {
                Connect-AzAccount -ErrorAction 'Stop'
            }
            catch {
                throw 'Unable to connect to AzAccount'
            }
        }
    }
    PROCESS {
        switch ($Subscription) {
            # Dev subscription
            'NonProd' {
                $Subscription = 'Non-Production'
                $SubscriptionID = $SubscriptionID.NonProd
            }
            'Non-Production' {
                $Subscription = 'Non-Production'
                $SubscriptionID = $SubscriptionID.NonProd
            }

            # Sandbox subscription
            'Sandbox' {
                $Subscription = 'Sandbox'
                $SubscriptionID = $SubscriptionID.Sandbox
            }
            'Sandbox' {
                $Subscription = 'Sandbox'
                $SubscriptionID = $SubscriptionID.Sandbox
            }

            # Production subscription
            'Prod' {
                $Subscription = 'Production'
                $SubscriptionID = $SubscriptionID.Prod
            }
            'Production' {
                $Subscription = 'Production'
                $SubscriptionID = $SubscriptionID.Prod
            }

            Default {
                throw 'No subscription selected, see paramerter help message'
            }
        }

        $Context = Get-AzContext -ErrorAction Stop

        if ($Context.Subscription.Name -ne $Subscription) {

            Set-AzContext -ErrorAction 'Stop' -SubscriptionName $SubscriptionID | Out-Null

        }
    }
    END {
        $host.ui.RawUI.WindowTitle = "$Subscription - $($context.Account.Id) - $((Get-Date).ToShortDateString())"
    }
}