#Requires -RunAsAdministrator
Set-StrictMode -Version 'Latest'

# Has to be admin to update REGEDIT and move files into correct location

if ($env:OneDrive.Contains('OneDrive - ')) {
    $profileLocation = "$env:OneDrive\User Profile"
    $RegKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    if((Test-Path $profileLocation) -eq $false) { mkdir $profileLocation }
    # These locations with GUID are for when redirecting to OneDrive 
    $ShellFolders = @{
        "Desktop"                                = "Desktop" 
        "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}" = "Downloads"
        "{31C0DD25-9439-4F12-BF41-7FF4EDA38722}" = "3D Objects"
        "{0DDD015D-B06C-45D5-8C4C-F59713854639}" = "Pictures"
        "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" = "Documents"
        "{35286A68-3C57-41A1-BBB1-0EAE73D76C95}" = "Videos"
        "{A0C69A99-21C8-4671-8703-7934162FCF1D}" = "Music"
    }

    # Print Current locations
    Get-ItemProperty -Path $RegKeyPath

    foreach ($Folder in $ShellFolders.GetEnumerator()) {
    
        $Name = $Folder.Key
        $Value = $Folder.Value
        $OnedriveFolder = "$profileLocation\$Value"

        try {            
            Write-Output "Moving folder: $ENV:USERPROFILE\$Value"
            Write-Output "New Location: $OnedriveFolder"
            Write-Output "~~~~~~~~~~~~~~~~~~~~~~~~~~~~`n"
            Move-Item -ErrorAction Stop `
                -ErrorVariable moveFile `
                -Path "$ENV:USERPROFILE\$Value" `
                -Destination "$OnedriveFolder" `
                -Force

            Write-Output "Updating Shell Folder: $Value"
            Write-Output "New Value: $OnedriveFolder`n"
            Set-ItemProperty -ErrorAction Stop `
                -ErrorVariable updateShellFolder `
                -Path $RegKeyPath `
                -Name $Name `
                -Value $OnedriveFolder # Reset values to default, by changing this value to -Value "$ENV:USERPROFILE\$Value"            
        }  
        catch {
            if ($updateShellFolder) { Write-Host -ForegroundColor Yellow "Update Shell Folder failed: $Value `n`n$updateShellFolder" }
            if ($moveFile) { Write-Host -ForegroundColor Yellow "Unable to move folder, possible file conflicts: $regkeyValue `n`n$moveFile" }
        }
    }

    Stop-Process -Name 'Explorer' 
    Start 'Explorer.exe'

}
else {
    Write-Warning "Sync OneDrive to the PC before running this script"
    # Sync down OneDrive folder
    START 'https://office.com'
}