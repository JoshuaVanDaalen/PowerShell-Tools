<# 
    Windows 7

    -Install Software
    -Join the BUSINESS domain 
    -Rename the PC
#>

#TODO: Add schedualed jobs to the Process block

param(

    [Parameter(Mandatory = $TRUE,
        HelpMessage = "Enter New Computer Name.")] 
    [String]
    $PCName,

    [Parameter(Mandatory = $TRUE,
        HelpMessage = "Enter Domain Name.")] 
    [String]
    $DomainName,

    [Parameter(Mandatory = $TRUE,
        HelpMessage = "Enter Admin Username.")] 
    [String]
    $AdminUsername
)

BEGIN {
    [bool] $RenameAndSetDNS = $false
    $Question = Read-Host -Prompt 'Have you done the following? Rename PC, Set DNS, & Reboot: Y/N'
    if ($Question.ToLower() == "y" ){
        $RenameAndSetDNS = $tr
    }
}

PROCESS { 
    if ($Question.ToLower() == "y" ){
        $RenameAndSetDNS = $tr
        
        #Create C:\installs folder.
        Write-host "Directory C:\installs was created." -foregroundcolor "Cyan"
        New-Item -ItemType "directory" -Path "c:\installs"

        #Download Chocolately.
        Write-Host "Downloading Chocolatey." -ForegroundColor "Cyan"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

        #Install google
        Write-host "Installing Google Chrome." -foregroundcolor "Cyan"
        choco install googlechrome -y
        Write-host "Google Chrome Installed." -foregroundcolor "Cyan"

        #Install Adobe PDF
        Write-host "Installing Adobe PDF Reader." -foregroundcolor "Cyan"
        choco install adobereader -y
        Write-host "Adobe PDF Reader Installed." -foregroundcolor "Cyan"

        Write-host "Installing TeamViewer." -foregroundcolor "Cyan"
        choco install teamviewer -y
        Write-host "TeamViewer Installed." -foregroundcolor "Cyan"
        
        #Join the domain & rename the PC
        Write-Host "Renaming computer to $PCName" -ForegroundColor "Cyan"
        Write-Host "Joining $DomainName domain" -ForegroundColor "Cyan"
        Add-Computer -DomainName $DomainName -Credential "$DomainName\$AdminUsername"  
        Write-Host "Restarting Computer" -ForegroundColor "Cyan"
    }
    else {
        Write-Host "Rename PC, Set DNS, & Reboot be trying again" -ForegroundColor "Cyan"
    }
}

END {
    Set-ExecutionPolicy Restricted
}
