


$subscriptions = Get-AzSubscription
$results = @()

foreach ($s in $subscriptions) {
    Set-AzContext $s.Id | Out-Null
    Start-Sleep -Seconds 15
    Set-AzContext $s.Id | Out-Null
    (Get-AzContext).Subscription.Name
    $roles = Get-AzRoleAssignment

    foreach ($r in $roles) {

        $Properties = @{
            RoleDefinitionName = $r.RoleDefinitionName
            SignInName         = $r.SignInName
            DisplayName        = $r.DisplayName
            Scope              = $r.Scope
            ObjectType         = $r.ObjectType
            Subscription       = $s.Name
        }

        $obj = New-Object -TypeName PSObject -Property $Properties

        $results += $obj
    }
}

$results
