
$RootDir = "C:/"
If (Test-Path $RootDir -eq $false) { mkdir $RootDir }

$FileLocation = "$RootDir/ProxyAutoConfiguration.js"
$ProxyServer = '192.168.0.200' # IP of Squid server
$Port = '3128' # Default Squid server port number

"function FindProxyForURL(url, host) {
    if (shExpMatch(host, '(*joshuavandaalen.com.au*)'))
        return 'PROXY $ProxyServer`:$Port';
    return 'DIRECT';    
}" > $FileLocation

$RegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

Set-ItemProperty -path $RegKey ProxyEnable -value 1
Set-ItemProperty -path $RegKey ProxyServer -value "$ProxyServer`:$Port"
Set-ItemProperty -path $RegKey AutoConfigURL -Value "file:///$FileLocation"
