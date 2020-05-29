
This is the DevOps guide to running PowerShell scripts and modules.

# Setup

## Installing AZ Module
I'd recommend downloading PowerShell version 7.1.0 Preview or newer and installing the AZ Modules to best work with Azure.
https://github.com/PowerShell/PowerShell


```powershell
# Install Az .
if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
      'Az modules installed at the same time is not supported.')
} else {
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    # Connect to Azure with a browser sign in token
    Connect-AzAccount
}
```

## Running scripts
To run a .ps1 script from the PowerShell console you have to dot source the file.
This is by design so that you only run scripts that you intended.

Note: Many of these scripts will require changing some initial variables.

Example:

```powershell
# Change to the folder you have the .ps1 file saved.
cd 'C:\Working Directory\'

# 
'.\New-Resource-Group.ps1'

```

## Using modules
Using a .psm1 file requres the module be loaded into a location on the $env:PSModulePath variable.
This variable can be updated but will revert to default when you open a new session.

To have your custom module path persist on the PSModulePath, update your $PROFILE.CurrentUserAllHosts file by adding the following line to the file.

Example:

```powershell
# Open notepad.
notepad $PROFILE.CurrentUserAllHosts

# Add the following line to the file, save the file, Open new PowerShell session.
$env:PSModulePath = "$env:PSModulePath" + ";C:\Modules;"

```

Note: The name of your folder name should match the .psm1 file 

Example:

```powershell
C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\AzADUser\AzADUser.psm1
```
