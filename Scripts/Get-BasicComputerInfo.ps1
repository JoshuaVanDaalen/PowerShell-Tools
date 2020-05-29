
$RAMINFO = Get-CimInstance win32_physicalmemory
$PCInfo = [PSCustomObject]@{

    'Computer Name'    = $ENV:COMPUTERNAME
    'CPU'              = (Get-CimInstance Win32_Processor).name
    'Hard Drive'       = "$((Get-PhysicalDisk)[0].FriendlyName): $((Get-PhysicalDisk)[0].MediaType)"
    'Free Space'       = [math]::Round((Get-CimInstance win32_logicaldisk | where caption -eq "C:").FreeSpace/1gb, 2).ToString() + "GB"
    'Operating System' = "$(Get-CimInstance Win32_OperatingSystem).Caption): $((Get-CimInStance CIM_OperatingSystem).OSArchitecture)"
    'RAM/ Speed'       = $RAMINFO | % { "$($_.Manufacturer) @ $($_.ConfiguredClockSpeed)" } 
    'Total RAM'        = $RAMINFO | Measure-Object -Property capacity -Sum | Foreach { "{0:N2}" -f ([math]::round(($_.Sum / 1GB), 2)).ToString() + "GB" }
    'Network Card'     = "$((Get-NetAdapter -Physical | Where { $_.Name -eq 'Ethernet' }).InterfaceDescription): $((Get-NetAdapter -Physical | Where { $_.Name -eq 'Ethernet' }).LinkSpeed)"
}; $PCInfo;
