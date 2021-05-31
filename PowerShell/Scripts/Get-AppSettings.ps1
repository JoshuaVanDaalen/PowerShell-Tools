#make appsettings.json

$app = Get-AzWebApp -Name 'app-publicapi-test'
$hashtable = @{}

foreach ($t in $app.SiteConfig.AppSettings ) {

      $hashtable += @{ "$($t.name)" = "$($t.Value)" }

}

$hashtable | ConvertTo-Json | clip


$hashtable.GetEnumerator() | sort key | ConvertTo-Json

$subs = Get-AzSubscription
$hashtable = @{}
$appFound = $false

ForEach ($sub in $subs) {
      "Sub: $($Sub.id)"
      Set-AzContext -ErrorAction Stop -SubscriptionId $sub.id | Out-Null
      $app = Get-AzWebApp -Name 'app-publicapi-dev'
      if ($app) {
            $appFound = $true
            foreach ($t in $app.SiteConfig.AppSettings ) {
                  $hashtable += @{ "$($t.name)" = "$($t.Value)" }
            }
            $hashtable | ConvertTo-Json
            "Break"
            break;
      }
}


#Get for Az Func
#func azure functionapp fetch-app-settings <Function App Name>
