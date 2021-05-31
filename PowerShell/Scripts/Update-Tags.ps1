


$ResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like '*dev*' }
$ResourceGroup | ForEach-Object { $_.Tags.Add("Environment", "PROD") }


$tags = @{
    "Environment" = "Development"
}


# Rename Resource Groups

$ResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like '*dev*' }
foreach ($rg in $ResourceGroup) {

    Set-AzResourceGroup -Id $rg.ResourceId -Tag $tags

}

# Rename Resources


$Resource = Get-AzResource | Where-Object { $_.Name -like '*dev*' -or $_.ResourceGroupName -like '*dev*' }
foreach ($rs in $Resource) {

    Set-AzResource -Id $rs.ResourceId -Tag $tags -Force

}



$Resource = Get-AzResource | Where-Object { $_.ResourceGroupName -like '*dev*' }
foreach ($rs in $Resource) {

    Set-AzResource -Id $rs.ResourceId -Tag $tags -Force

}



$azr = Get-AzResource | Where-Object { $_.Name -like '*dev*' }

$azRES = $azr | Select-Object name, ResourceType