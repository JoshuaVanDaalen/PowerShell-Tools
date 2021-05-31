
# businessstgaccctestshared

$env = 'test'
$client = 'Sonnen'

$ResourceGroupName = 'business-prod'
$StorageAccountName = 'stproductausseprod'


$destinationStorageAccountName = 'businessstgaccctestshared'

# azcopy copy 'https://<source-storage-account-name>.blob.core.windows.net/<container-name>/<directory-path><SAS-token>' 'https://<destination-storage-account-name>.blob.core.windows.net/<container-name>' --recursive

# azcopy copy 'https://mysourceaccount.blob.core.windows.net/mycontainer/myBlobDirectory?sv=2018-03-28&ss=bfqt&srt=sco&sp=rwdlacup&se=2019-07-04T05:30:08Z&st=2019-07-03T21:30:08Z&spr=https&sig=CAftvB=ska7bQA8%3D' 'https://mydestinationaccount.blob.core.windows.net/mycontainer' --recursive



$sourceUrlBase = "https://$StorageAccountName.blob.core.windows.net"
$destinationUrlBase = "https://$destinationStorageAccountName.blob.core.windows.net"


$ResourceGroup = Get-AzResourceGroup `
    -ErrorAction 'Stop' `
    -Name $ResourceGroupName

$StorageAccount = Get-AzStorageAccount `
    -ErrorAction 'Stop' `
    -ResourceGroupName ($ResourceGroup).ResourceGroupName `
    -Name $StorageAccountName

$StorageAccountAccessKey = (Get-AzStorageAccountKey `
        -ErrorAction 'Stop' `
        -ResourceGroupName ($ResourceGroup).ResourceGroupName `
        -AccountName $StorageAccount.StorageAccountName).value[0]

$StorageContainer = Get-AzStorageAccount `
    -ErrorAction 'Stop' `
    -ResourceGroupName ($ResourceGroup).ResourceGroupName `
    -Name $StorageAccountName | Get-AzStorageContainer -ErrorAction 'Stop'


$StorageAccountAccessKey = (Get-AzStorageAccountKey `
        -ErrorAction 'Stop' `
        -ResourceGroupName $ResourceGroupName `
        -AccountName $StorageAccount.StorageAccountName).value[0]

$sourceStorageAccountAccessKey = '?sv=2020-02-10&ss=bfqt&srt=sco&sp=rwdlacupx&se=2021-04-06T15:06:21Z&st=2021-04-06T07:06:21Z&spr=https&sig=eVex9yT8WVK0%3D'

$StorageUri = ($StorageContainer | ? { $_.Name -eq 'dbexports' }).BlobContainerClient.Uri.AbsoluteUri




$subs = Get-AzSubscription
ForEach ($sub in $subs) {

    Set-AzContext -ErrorAction Stop -SubscriptionId $sub.id

    $rgList = Get-AzResourceGroup

    ForEach ($ResourceGroup in $rgList) {
        # Write-Host -ForegroundColor Yellow $ResourceGroup.ResourceGroupName
        # Get stroage accounts
        $stList = Get-AzStorageAccount `
            -ErrorAction 'Stop' `
            -ResourceGroupName ($ResourceGroup).ResourceGroupName

        foreach ($StorageAccount in $stList) {
            # Write-Host -ForegroundColor Yellow $StorageAccount.StorageAccountName

            # Get stroage account containers
            $stContrainerList = $StorageAccount | Get-AzStorageContainer -ErrorAction 'Stop'

            # Write-Host -ForegroundColor Yellow $StorageContainer.Name
            foreach ($stContrainer in $stContrainerList) {

                if ($stContrainer.Name -like "*$client*" -and $stContrainer.Name -notlike "*sandbox*") {


                    $sourceUrlBase = "https://$StorageAccountName.blob.core.windows.net"
                    $destinationUrlBase = "https://$destinationStorageAccountName.blob.core.windows.net"

                    # azcopy copy 'https://<source-storage-account-name>.blob.core.windows.net/<container-name><SAS-token>'
                    #'https://<destination-storage-account-name>.blob.core.windows.net/<container-name>' --recursive

                    $sourceUrl = "$sourceUrlBase/$($stContrainer.Name)$sourceStorageAccountAccessKey"
                    $destinationUrl = "$destinationUrlBase/$env-$($stContrainer.Name)"

                    $Properties = @{
                        'StorageContainer' = $stContrainer.Name
                        'PublicAccess'     = $stContrainer.PublicAccess
                        'ResourceGroup'    = $StorageAccount.ResourceGroupName
                        'StorageAccount'   = $StorageAccount.StorageAccountName
                        'sourceUrl'        = $sourceUrl
                        'destinationUrl'   = $destinationUrl
                    }
                    $obj = New-Object -TypeName PSObject -Property $Properties

                    # $obj
                    azcopy copy "$sourceUrl" "$destinationUrl" --recursive

                }



                if ($stContrainer.PublicAccess -ne 'Off') {
                    $Properties = @{
                        'StorageContainer' = $stContrainer.Name
                        'PublicAccess'     = $stContrainer.PublicAccess
                        'ResourceGroup'    = $StorageAccount.ResourceGroupName
                        'StorageAccount'   = $StorageAccount.StorageAccountName
                    }
                    $obj = New-Object -TypeName PSObject -Property $Properties
                    $obj | Export-Csv -Append 'D:\publicStorageContainers.csv'
                }
            }
        }
    }
}

$StorageContainer = Get-AzStorageAccount `
    -ErrorAction 'Stop' `
    -ResourceGroupName ($ResourceGroup).ResourceGroupName `
    -Name $StorageAccountName | Get-AzStorageContainer -ErrorAction 'Stop'