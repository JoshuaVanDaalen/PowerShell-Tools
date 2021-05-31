


$subs = Get-AzSubscription
ForEach ($sub in $subs) {

    Set-AzContext -ErrorAction Stop -SubscriptionId $sub.id

    $apps = Get-AzWebApp

    ForEach ($app in $apps) {

        $myapp = Get-AzWebApp -ResourceGroupName $app.ResourceGroup -Name $app.Name | Where-Object { $_.SiteConfig.AppSettings.Value -like "*func-comm*" }
        # $myapp = Get-AzWebApp -ResourceGroupName $app.ResourceGroup -Name $app.Name | ? {$_.Type -eq "Microsoft.Web/sites"}
        if ($myapp.Name.Length -gt 1) {
            Write-Host "$($myapp.Name)" -ForegroundColor Yellow
        }
        # TODO: Get function app settings
    }
}


#Get for Az Func
#func azure functionapp fetch-app-settings <Function App Name>
