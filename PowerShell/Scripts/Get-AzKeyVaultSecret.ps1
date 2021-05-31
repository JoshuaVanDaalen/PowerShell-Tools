

$Var = @{
    VaultName                       = 'kv-companyname-uat'
    ResourceGroupName               = 'rg-companyname-test'
    ServiceBusNamespace             = 'sb-companyname-test'
    companynameSharedBlobStorage    = 'companynamestorageaccount'
    OldSufix                        = '-uat'
    NewSufix                        = '-test'
    companynameAppPw                = '5555555555555555555'
}

#Get-AzureKeyVaultKey -VaultName $Var.VaultName

$Secerts = Get-AzKeyVaultSecret `
    -VaultName $Var.VaultName


$companynameServiceBusConnection = (Get-AzServiceBusKey `
        -ResourceGroupName $Var.ResourceGroupName `
        -Namespace $Var.ServiceBusNamespace `
        -Name 'RootManageSharedAccessKey').PrimaryConnectionString

$companynameSharedBlobStorage = Get-AzStorageAccountKey `
    -ResourceGroupName $Var.ResourceGroupName `
    -Name $Var.companynameSharedBlobStorage 

foreach ($s in $Secerts) {

    # This is how you get the value, $s.SecretValueText doesn't exist
    $secret = Get-AzKeyVaultSecret -VaultName $Var.VaultName -Name $s.Name
    $secretName = $secret.Name
    $secretValue = $secret.SecretValueText
    $secretValue = $secretValue.Replace($Var.OldSufix, $Var.NewSufix)


    if ($secretName.Contains("User ID=companyname_app;Password=")) {
                $t = $secretName
        $dbConnSubstring = $secretValue.Substring($secretValue.IndexOf('User ID=companyname_app;Password='))
        $dbConnPw = $dbConnSubstring.Substring($dbConnSubstring.IndexOf('User ID=companyname_app;Password='), $dbConnSubstring.IndexOf(';'))
        $secretValue =$secretValue.Replace($dbConnPw, "User ID=companyname_app;Password==$($Var.companynameAppPw)")

    }
    

    if ($secretName -eq 'companynameServiceBusConnection') {

        $secretValue = $companynameServiceBusConnection
    }
    
    if ($secretName -eq 'companynameSharedBlobStorageConnection') {
        
        $SecretValueText = $secret.SecretValueText

        $stNameSubstring = $SecretValueText.Substring($SecretValueText.IndexOf('AccountName='))
        $stName = $stNameSubstring.Substring($stNameSubstring.IndexOf('AccountName='), $stNameSubstring.IndexOf(';'))
        $SecretValueText = $SecretValueText.Replace($stName, "AccountName=$($Var.companynameSharedBlobStorage)")

        $stKeySubstring = $SecretValueText.Substring($SecretValueText.IndexOf('AccountKey='))
        $stKey = $stKeySubstring.Substring($stKeySubstring.IndexOf('AccountKey='), $stKeySubstring.IndexOf(';'))
        $SecretValueText = $SecretValueText.Replace($stKey, "AccountKey=$($companynameSharedBlobStorage[0].Value)")

        $secretValue = $SecretValueText

    }

    Write-Host "secretName:  $secretName"
    Write-Host "secretValue: $secretValue"
    Write-Host ""
    # $uatSecret = $secret.Replace("-uat", "-test")

    #Set-AzKeyVaultSecret -VaultName $Var.VaultName  -Name $secret.Name -SecretValue $secret.SecretValueText

}
    