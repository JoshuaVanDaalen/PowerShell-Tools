function Extract-BUSINESSArchive {
    
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory)]        
        [string]$Path
        
    )
    # Unzip all folders
    $root = ls $Path    

    foreach ($dir in $root) {
        $zipFullName = $dir.fullname
        $zipName = $dir.name
        $zipName = $zipName.Substring(0, ($zipName.Length - 4))
        
        Expand-Archive -DestinationPath "$Path\$zipName" -Path $dir.FullName
        rmdir $zipFullName
    }
}



function Expand-BUSINESSArchive {

    [cmdletBinding()]
    Param (
        [Parameter(Mandatory)]        
        [string]$Path
        
    )

    $XMLRootFolderPath = $Path
    $XMLRootFolderContents = ls $XMLRootFolderPath

    foreach ($outterFolder in $XMLRootFolderContents) { 

        #Root folder name
        $FolderName = $outterFolder.name

        #Get Zip folders within each root folder
        $zipfolders = ls $outterFolder.fullname -Recurse | where { $_.Name -like '*.zip' }

        #Extract zip folders into rootfolder
        foreach ($zip in $zipfolders) {
        
            $zipFullName = $zip.FullName
            $zipName = $zip.Name
            
            try {
                Move-Item -Path $zipFullName -Destination "$XMLRootFolderPath\$zipName" -ErrorAction Stop
            }
            catch {
                if ($mvFailed) {
                    Write-Host -ForegroundColor Red $mvFailed
                }
            }
        }
        rmdir "$XMLRootFolderPath\$FolderName" -Recurse
    }    
}


# Unzip all folders
# $root = ls 'C:\Temp\20200225'

# foreach($dir in $root){
# $zipFullName = $dir.fullname
# $zipName = $dir.name
# $zipName = $zipName.Substring(0,($zipName.Length -4))

# Expand-Archive -DestinationPath "C:\Temp\20200225\$zipName" -Path $dir.FullName
# rmdir $zipFullName
# }



