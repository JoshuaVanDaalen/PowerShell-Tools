<# 
    -Install Software
    -Join the BUSINESS domain 
    -Rename the PC
#>

#TODO: Add schedualed jobs to the Process block

    param(

        [Parameter(Mandatory=$TRUE,
                    HelpMessage="Enter New Computer Name.")] 
                    [String]
                    $NewName,

        [Parameter(Mandatory=$TRUE,
                    HelpMessage="Enter Domain Name.")] 
                    [String]
                    $DomainName                    
        )

    BEGIN {
    
        $DomainName = ""

    }

    PROCESS { 
     
        #Create C:\installs folder.
        Write-host "Directory C:\installs was created." -foregroundcolor "Green"
        New-Item -ItemType "directory" -Path "c:\installs"

        #Download Chocolately.
        Write-Host "Downloading Chocolatey." -ForegroundColor "Green"
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

        #Install google
        Write-host "Installing Google Chrome." -foregroundcolor "green"
        choco install googlechrome -y
        Write-host "Google Chrome Installed." -foregroundcolor "green"

        #Install Adobe PDF
        Write-host "Installing Adobe PDF Reader." -foregroundcolor "green"
        choco install adobereader -y
        Write-host "Adobe PDF Reader Installed." -foregroundcolor "green"
    
        #Join the domain & rename the PC
        Write-Host "Renaming computer to $NewName" -ForegroundColor "Green"
        Write-Host "Joining $DomainName domain" -ForegroundColor "Green"
        Add-Computer -ComputerName localhost -DomainName $DomainName -NewName $NewName -Credential -Restart -Force
        Write-Host "Restarting Computer" -ForegroundColor "Green"

    }

    END {
    
        Set-ExecutionPolicy restricted

        #Write-Host "Press any key to exit..."

        #$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    }
