# Dashboard_Kit

All notable changes to the "Dashboard_Kit" Module will be documented in this file.


## [Unreleased]
* working on a better implementation for VF's
* working on a better implementation to comparing Defined Zone Configurations with the Effective Zone Configuration 
* better differentiation between zones and peerzones
* more or better integration of information at porterrshow/ portbuffershow
* include SFP Information as far as useful
* include FOS information as far as useful
* include connected Deviceinformation (Host/Storage/ etc.)
* include the possibility of comparisons with older data ( trend over periodtime).
* Possibilities of integrating an automatic service (Win & later other OS)

## 0.1.0 beta
### Saturday, June 08, 2024
Improvemnt:
* Code optimization for Port Basic show -> PortConnect

Fixed:
* Switch Fabric OS was not displayed 
* PortConnect was displayed incorrectly 

Removed:
* Temporary removed - support for VF, this part needs a complete overhaul.
* Clean up Readme

Known Issues
* Zone Information in in combination with FOS older then 8.1.x may sometimes makes an incorrect assignment between WWPN and alias, but this only affects host aliases
    * the view zone in combination with WWPNs, on the other hand, is correct

## 0.0.2 alpha
### Friday, May 10, 2024
Added:
* some older Switch Typs
* MaskInput for Password

Improvemnt:
* updated, readme file for installation
* removed, unnecessary lines of code 

Fixed:
* Password problem with plink connection
* ordering of the values in a hastable to display the basic and adv. switch info
* update some write-host text
* language translation error

Removed:
* Temporary removed - support for VF, this part needs a complete overhaul.

## 0.0.1 alpha
### Friday, May 03, 2024
Initial release with the following features:

* initial release
* supports the commands from FOS 8.2.x untill 9.x
* supports the pwsh 5.1 and 7.4.x



Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.
