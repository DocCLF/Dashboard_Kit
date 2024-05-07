# Dashboard Kit

The dashboard kit collects various information about the SAN switches specified (in the first version) and makes it available on an HTML page. 
I created this kit to get a quick overview of an existing SAN infrastructure without having to log in to x switches with x commands. 
I am aware that there are products from various manufacturers on the market for this purpose, but very few of them meet my requirements!

To Sart the function call: Open_Brocade_Dashboard

... further motives or information will follow ...

### Installing
```powershell
Install-Module -Name Dashboard_Kit -AllowClobber -AllowPrerelease -Force
```
If the module is not activated automatically, then it is necessary to import it later, depending on the version of PowerShell (see Pic).
```powershell
Import-Module Dashboard_Kit
```
<img width="1897" alt="Unbenannt" src="https://github.com/DocCLF/Dashboard_Kit/assets/9890682/198bb199-640f-49e6-9d22-96cdd7f4ffc5">

### Import
Download it from Git and Import it manually
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

## Pictures
Main page, overview with (in my opinion) important information about the switch.
<img width="1897" alt="dashboard_overview" src="https://github.com/DocCLF/Dashboard_Kit/assets/9890682/397b7dea-e360-404f-a7d0-39aac8a62453">

Effective configuration (Zoning)
<img width="1605" alt="zoning_overview" src="https://github.com/DocCLF/Dashboard_Kit/assets/9890682/35f10dfc-1272-4228-80b3-b0f85a8b47f9">

## For more information

* [Dashboard_Kit](https://github.com/DocCLF/Dashboard_Kit)
* or contact me here or linkedin

**Enjoy!**
