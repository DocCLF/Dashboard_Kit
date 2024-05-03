# Dashboard Kit

The dashboard kit collects various information about the SAN switches specified (in the first version) and makes it available on an HTML page. 
I created this kit to get a quick overview of an existing SAN infrastructure without having to log in to x switches with x commands. 
I am aware that there are products from various manufacturers on the market for this purpose, but very few of them meet my requirements!

To Sart the function call: Open_Brocade_Dashboard

... further motives or information will follow ...

### Installing (NOT WORKING at THE Moment use Import-Module)
```powershell
Install-Module -Name Dashboard_Kit -AllowClobber -Force
```
Change change directory with: cd c:\<path>\Dashboard_kit\
Import-Module is a temporary installation, which will be deleted after closing the powershell.
```powershell
Import-Module ".\Dashboard_Kit.psm1" -Force -NoClobber
```

Force and AllowClobber aren't necessary but they do skip errors in case some appear.

### Updating
```powershell
Update-Module -Name Dashboard_Kit
```
That's it. Whenever there's a new version you simply run the command and you can enjoy it. Remember, that you may need to close, reopen the PowerShell session if you have already used the module before updating it.


## What comes next
* information will follow

## Requirements
[PowerShell][] 5.1 or 7.4.x\
[PSWriteHTML][]- PowerShell Module v1.17.0 
* If PSWriteHTML is not installed, it can be installed automatically after the start the function with: Open_Brocade_Dashboard

[PowerShell]: https://github.com/PowerShell/PowerShell
[PSWriteHTML]: https://github.com/EvotecIT/PSWriteHTML

## Known Issues

* Some information may not be displayed completely, depending on the browser
* Information may be missing for switches with a FOS older than 8.2.x 
* It can lead to error messages due to user rights within the powershell
    * To run the script you may have to enter the following line in Powershell before you can use the script.\
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser\
      or\
      Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
* There is no key signature for the module itself yet

## Release Notes

See [changelog](CHANGELOG.md) for all changes and releases.

## For more information

* [Dashboard_Kit](https://github.com/DocCLF/Dashboard_Kit)

**Enjoy!**
