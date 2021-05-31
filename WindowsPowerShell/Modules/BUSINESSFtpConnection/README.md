
Refer to the main README.md on using modules to run this module.

# Test the connection to a FTP server
Make a connection to an FTP server that you can reach from your network.
In example 2, you must be able to reach the MSATS FTP server from your machine without using the VPN/ Proxy.

## Example 1
In Example 1 the FTP server is specified and returns the content from the web request method.

```powershell
Test-TallyFtpConnection `
     -Username 'could-by-this' `
     -Password 'BigOlPasswordThatWasRemoved' `
     -FtpServer '14.80.136.101'
```

![alt text](https://tallyitshared.blob.core.windows.net/gitimages/Test-TallyFtpConnection-01.png)


## Example 2
In Example 2 we are asked which MSATS FTP server we want to test the connection to.
```powershell
Test-TallyFtpConnection -Username 'nemnet/joshvd' -Password 'ThisIsNotMyPassword'
```


![alt text](https://tallyitshared.blob.core.windows.net/gitimages/Test-TallyFtpConnection-02.png)
