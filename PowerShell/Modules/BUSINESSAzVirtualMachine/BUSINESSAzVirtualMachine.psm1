#Requires –Modules Az
#Written by Joshua Van Daalen.
function New-BUSINESSAzVirtualMachine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$AzContextName,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$VMName,

        [Parameter()]
        [string]$Location = 'Australia East',

        [Parameter(Mandatory = $True,
            HelpMessage = 'For IP (pip-$ResourcePrefix) and NIC (nic-$ResourcePrefix).')]
        [string]$ResourcePrefix,

        [Parameter(Mandatory = $True,
            HelpMessage = 'VNet Name?')]
        [string]$VNetName
    )

    begin {
        $context = Set-BUSINESSAzContext -Env $AzContextName
    }

    process {

        $randomNumber = (Get-Random -Maximum 250 -Minimum 10).ToString()
        $locationObj = Get-AzLocation | ? { $_.DisplayName -like $Location }

        $Var = @{
            PublicIpAddressName  = "pip-$ResourcePrefix-$randomNumber"
            NetworkInterfaceName = "nic-$ResourcePrefix-$randomNumber"
            Location             = $locationObj.Location
            VMSize               = 'Standard_B4ms'
            VMDiskName           = "$($VMName)_OSDisk_0.vhd"
            NSGName              = "nsg-rdpallow-$randomNumber"
        }
        try {
            Write-Verbose "Locating: $VNetName"
            $VNet = Get-AzVirtualNetwork `
                -Name $VNetName

            Write-Verbose "Creating Public Ip Address: $($Var.PublicIpAddressName)"
            $PIP = New-AzPublicIpAddress `
                -ErrorAction 'Stop' `
                -Name $Var.PublicIpAddressName `
                -ResourceGroupName $ResourceGroupName `
                -Location $Var.Location `
                -AllocationMethod 'Dynamic' `
                -WarningAction 'SilentlyContinue'

            Write-Verbose "Creating Network Security Rule Config"
            $rdpRule = New-AzNetworkSecurityRuleConfig `
                -ErrorAction 'Stop' `
                -Name 'RDP' `
                -Description 'Allow RDP' `
                -Access 'Allow' `
                -Protocol 'Tcp' `
                -Direction 'Inbound' `
                -Priority 110 `
                -SourceAddressPrefix (Invoke-WebRequest ifconfig.me/ip).Content.Trim() `
                -SourcePortRange * `
                -DestinationAddressPrefix * `
                -DestinationPortRange 3389

            Write-Verbose "Creating Network Security Group"
            $NSG = New-AzNetworkSecurityGroup `
                -ErrorAction 'Stop' `
                -ResourceGroupName $ResourceGroupName `
                -Location $locationObj.DisplayName `
                -Name $Var.NSGName `
                -SecurityRules $rdpRule

            Write-Verbose "Creating Network Interface: $($Var.NetworkInterfaceName)"
            $NIC = New-AzNetworkInterface `
                -ErrorAction 'Stop' `
                -Name $Var.NetworkInterfaceName `
                -ResourceGroupName $ResourceGroupName `
                -Location $Var.Location `
                -SubnetId $Vnet.Subnets[0].Id `
                -PublicIpAddressId $PIP.Id `
                -NetworkSecurityGroupId $NSG.Id

            Write-Verbose "Setting VM size: $($Var.VMSize)"
            $VirtualMachine = New-AzVMConfig `
                -ErrorAction 'Stop' `
                -VMName $VMName `
                -VMSize $Var.VMSize

            $Day = (Get-date).Day.ToString()
            $Month = (Get-date).Month.ToString()
            if ($Day.length -eq 1) { $Day = "0$Day" }
            if ($Month.length -eq 1) { $Month = "0$Month" }

            $VMLocalAdminSecurePassword = ConvertTo-SecureString `
                -String "@Date$Month$Day" `
                -AsPlainText `
                -Force

            $VMLocalAdminUser = 'BUSINESSAdmin'
            $Credential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

            Write-Verbose "Setting VM operating system"
            $VirtualMachine = Set-AzVMOperatingSystem `
                -ErrorAction 'Stop' `
                -VM $VirtualMachine `
                -ComputerName $VMName `
                -Credential $Credential `
                -Windows

            Write-Verbose "Setting Network Interface"
            $VirtualMachine = Add-AzVMNetworkInterface `
                -ErrorAction 'Stop' `
                -VM $VirtualMachine `
                -Id $NIC.Id `

            Write-Verbose "Setting VM Source Image"
            $VirtualMachine = Set-AzVMSourceImage `
                -ErrorAction 'Stop' `
                -VM $VirtualMachine `
                -PublisherName 'MicrosoftWindowsDesktop' `
                -Offer 'Windows-10' `
                -Skus '20h1-pro' `
                -Version 'latest'

            Write-Verbose "Setting OS Disk: $($Var.VMDiskName)"
            $VirtualMachine = Set-AzVMOSDisk `
                -ErrorAction 'Stop' `
                -VM $VirtualMachine `
                -Name "$($Var.VMDiskName)" `
                -DiskSizeInGB 128 `
                -CreateOption 'fromImage' `
                -StorageAccountType 'Standard_LRS' `
                -Windows

            Write-Verbose "Disabling VM Boot Diagnostics"
            $VirtualMachine = Set-AzVMBootDiagnostic `
                -ErrorAction 'Stop' `
                -VM $VirtualMachine `
                -Disable

            Write-Verbose "Creating new VM: $VMName"
            New-AzVM `
                -ErrorAction 'Stop' `
                -ResourceGroupName $ResourceGroupName `
                -Location $locationObj.DisplayName `
                -VM $VirtualMachine

            $tags = New-Object 'system.collections.generic.dictionary[string,string]'
            $tags.Add('Owner', $VMName)

            $Disk = Get-AzDisk `
                -ResourceGroupName $ResourceGroupName `
                -DiskName $Var.VMDiskName
            $Disk.Tags = $tags
            $Disk | Update-AzDisk | Out-Null

            $Nsg = Get-AzNetworkSecurityGroup `
                -ResourceGroupName $ResourceGroupName `
                -Name $Var.NSGName
            $Nsg.Tag = $tags # Yes this is inconsistent with AzDisk
            $Nsg | Set-AzNetworkSecurityGroup | Out-Null

            $Pip = Get-AzPublicIpAddress `
                -ResourceGroupName $ResourceGroupName `
                -Name $Var.PublicIpAddressName
            $Pip.Tag = $tags # Yes this is inconsistent with AzDisk
            $Pip | Set-AzPublicIpAddress | Out-Null

            $Nic = Get-AzNetworkInterface `
                -ResourceGroupName $ResourceGroupName `
                -Name $Var.NetworkInterfaceName
            $Nic.Tag = $tags # Yes this is inconsistent with AzDisk
            $Nic | Set-AzNetworkInterface | Out-Null

        }
        catch {

            Write-Host "Error, rolling back changes" -ForegroundColor 'Red'
            $_
            Get-AzNetworkInterface -Name $Var.NetworkInterfaceName | Remove-AzNetworkInterface -Force
            Get-AzPublicIpAddress -Name $Var.PublicIpAddressName | Remove-AzPublicIpAddress -Force
            Get-AzNetworkSecurityGroup -Name $Var.NSGName | Remove-AzNetworkSecurityGroup -Force
            Get-AzDisk -Name $Var.VMDiskName | Remove-AzDisk -Force

        }
    }

    end {

    }
}