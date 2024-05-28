
# there a lot of "errors" in combination with substring Parameter, thats why "silentlycontinue"
$ErrorActionPreference="SilentlyContinue"
$DebugPreference="SilentlyContinue"

function Dashboard_MainFuncion {

    <#
    .SYNOPSIS
        Includes all sub-functions
    .DESCRIPTION
        Includes all sub-functions and can be expanded and reduced as required, making it easier to maintain overall. 
        If a sub-function is removed, this should also be removed from the html call at the end.
    .NOTES
        The function has so far only been tested under Windows, the application is still in alpha status.
    .LINK
        https://github.com/DocCLF/Dashboard_Kit/blob/main/Scripts/Dashboard_Mainfile.ps1
    .EXAMPLE

    #>  
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $FOS_CollectedDeviceInfos
    )

    #region BasisInfosSwitch
    $FOS_BasicSwitchInfo = GET_BasicSwitchInfos -FOS_MainInformation $FOS_CollectedDeviceInfos
    <#------------------- BasisInfosSwitch -----------------------#>
    #endregion

    #region Switchshow
    $FOS_SwitchShowInfo, $FOS_SwitchusedPorts = GET_SwitchShowInfo -FOS_MainInformation $FOS_CollectedDeviceInfos
    <#------------------- Switchshow -----------------------#>
    #endregion

    #region LogicalSwitch
    <#----------- LogicalSwitch/ FID Infos -----------#>
    <#----------- Unique information of the switch -----------#>
    $FOS_UniqueSwitchInfo = GET_UniqueSwitchInfos -FOS_MainInformation $FOS_CollectedDeviceInfos
    <#----------- Logical Switch/ FID Infos -----------#>
    #endregion

    #region Porterrshow
    $FOS_PortErrShow = GET_PortErrShowInfos -FOS_MainInformation $FOS_CollectedDeviceInfos -FOS_GetUsedPorts $FOS_SwitchusedPorts
    <#------------------- Porterrshow -----------------------#>
    #endregion

    #region Portbuffershow
    $FOS_PortBuffershow = Get_PortbufferShowInfo -FOS_MainInformation $FOS_CollectedDeviceInfos
    <#------------------- Portbuffershow -----------------------#>
    #endregion

    #region Zoning
    if($FOS_SwBasicInfosold -ne $FOS_UniqueSwitchInfo[1]){
        $FOS_ZoningInfo = GET_ZoneDetails -FOS_MainInformation $FOS_CollectedDeviceInfos #|Select-Object -Skip 2
        $FOS_SwBasicInfosold = $FOS_UniqueSwitchInfo[1]
    }else {
        <# Action when all if and elseif conditions are false #>
        Write-Debug -Message "$FOS_SwBasicInfosold is equal $($FOS_UniqueSwitchInfo[1])"
    }
   <#------------------- Zoning -----------------------#>
    #endregion

    #region HTML - Creation
    Dashboard -Name "Brocade Testboard" -FilePath $Env:TEMP\Dashboard.html {
    Tab -Name "Info of $($FOS_UniqueSwitchInfo[0])" -IconSolid server -IconColor LightGreen {
            Section -Name "More Info 1" -Invisible {
                Section -Name "Basic Information" {
                    Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_BasicSwitchInfo
                }
                Section -Name "Advanced Information" {
                    Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_UniqueSwitchInfo
                }
            }
            Section -Name "bluber" -Invisible{
                Section -Name "Basic Port Information" {
                    New-HTMLChart{
                        New-ChartPie -Name "Available Ports" -Value $($FOS_SwitchShowInfo.Count) -Color Green
                        New-ChartPie -Name "Used Ports" -Value $($FOS_SwitchusedPorts.count) -Color Red
                    }
                }
                Section -Name "Used Port Speed Allocation" {
                    New-HTMLChart{
                        New-ChartPie -Name "64G" -Value $(($FOS_SwitchShowInfo |Where-Object {$_.Speed -eq "N64"}).count)
                        New-ChartPie -Name "32G" -Value $(($FOS_SwitchShowInfo |Where-Object {$_.Speed -eq "N32"}).count)
                        New-ChartPie -Name "16G" -Value $(($FOS_SwitchShowInfo |Where-Object {$_.Speed -eq "N16"}).count)
                        New-ChartPie -Name "8G" -Value $(($FOS_SwitchShowInfo |Where-Object {$_.Speed -eq "N8"}).count)
                        New-ChartPie -Name "4G" -Value $(($FOS_SwitchShowInfo |Where-Object {$_.Speed -eq "N4"}).count)
                    }
                }
            }
            Section -Name "Port Info" -Invisible{
                Section -Name "Port Basic Show" -CanCollapse {
                    Table -HideFooter -DataTable $FOS_SwitchShowInfo{
                        TableConditionalFormatting -Name 'State' -ComparisonType string -Operator eq -Value 'Online' -BackgroundColor LightGreen -Row
                        TableConditionalFormatting -Name 'State' -ComparisonType string -Operator eq -Value 'No_Module' -BackgroundColor LightGray -Row
                    }
                }
                Section -Name "Port Buffer Show" -CanCollapse {
                    Table -HideFooter -DataTable $FOS_PortBuffershow {
                        EmailTableHeader -Names 'Port' -Title 'User' 
                        EmailTableHeader -Names 'Type' -Title 'Port' 
                        EmailTableHeader -Names 'Mode' -Title 'Lx'
                        EmailTableHeader -Names 'Max_Resv' -Title 'Buffers'
                        EmailTableHeader -Names 'Tx','Rx' -Title 'Avg Buffer Usage & FrameSize'
                        EmailTableHeader -Names 'Usage' -Title 'Buffers' 
                        EmailTableHeader -Names 'Buffers' -Title 'Needed' 
                        EmailTableHeader -Names 'Distance' -Title 'Link' 
                        EmailTableHeader -Names 'Buffer' -Title 'Remaining' 
                    }
                }

            }
            Section -Name "Port Info" -Invisible{
                Section -name "Port Error Show" -CanCollapse   {
                    Table -HideFooter -DataTable $FOS_PortErrShow{
                        TableConditionalFormatting -Name 'disc_c3' -ComparisonType number -Operator gt -Value 200 -BackgroundColor LightGoldenrodYellow
                        TableConditionalFormatting -Name 'disc_c3' -ComparisonType number -Operator gt -Value 400 -BackgroundColor OrangeRed
                        TableConditionalFormatting -Name 'link_fail' -ComparisonType number -Operator gt -Value 3 -BackgroundColor LightGoldenrodYellow
                        TableConditionalFormatting -Name 'link_fail' -ComparisonType number -Operator gt -Value 6 -BackgroundColor OrangeRed
                        TableConditionalFormatting -Name 'loss_sig' -ComparisonType number -Operator gt -Value 1 -BackgroundColor LightGoldenrodYellow
                    }
                }
            }
        }
    
        Tab -Name "Zone Inforamtion" {
            Section -Name "More Info 1" -Invisible {
                Section -Name "Zone Information" {
                    Table -HideFooter -DisablePaging -DataTable $FOS_ZoningInfo
                }
            }
        }
        
        <#'Tab -Name "Placeholder" {
            New-HTMLDiagram {
                #New-DiagramOptionsPhysics -Enabled $true
                New-DiagramOptionsInteraction -Hover $true
                #New-DiagramOptionsLayout -RandomSeed 50
                New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromUpToDown
                New-DiagramNode -Id $($FOS_ZoneOverview.WWPN[321]) -Label $($FOS_ZoneOverview.Alias[321]) -Level 1 -IconSolid server -IconColor Red
                New-DiagramNode -Id $($FOS_ZoneOverview.WWPN[319]) -Label $($FOS_ZoneOverview.Alias[319]) -Level 2 -To $($FOS_ZoneOverview.WWPN[321]) -IconSolid database
                New-DiagramNode -Id $($FOS_ZoneOverview.WWPN[320]) -Label $($FOS_ZoneOverview.Alias[320]) -Level 2 -To $($FOS_ZoneOverview.WWPN[321]) -IconSolid database
                
            }
        }#>
    }
}

function Open_Brocade_Dashboard {

    <#
    .SYNOPSIS
        Main function
    .DESCRIPTION
        Main function that checks the inventory for its prerequisites and then triggers all other functions.
    .NOTES
        The function has so far only been tested under Windows, the application is still in alpha status.
        This script supports the common parameters: Verbose, Debug
    .LINK
        https://github.com/DocCLF/Dashboard_Kit
    .EXAMPLE
        Open_Brocade_Dashboard
        or
        Open_Brocade_Dashboard -Debug
    #>
    
    [CmdletBinding()]
    param (

    )
    
    begin{
        <# This check is necessary because the "RequiredModules" entry in the *psd1 file does not work. For the test phase this "q&d" solution is good enough. #>
        [string]$Version="1.17.0"
        $RequiredModule = Get-Module -ListAvailable -Name PSWriteHTML | Sort-Object -Property Version -Descending | Select-Object -First 1
        $ModuleVersion = "$($RequiredModule.Version.Major)" + "." + "$($RequiredModule.Version.Minor)" + "." + "$($RequiredModule.Version.Build)"
        Write-Debug -Message $ModuleVersion
        if ($ModuleVersion -eq "..")  {
            Write-Host "PSWriteHTML $Version is required to run the Brocade Dashboard Report.`nRun 'Install-Module -Name PSWriteHTML -RequiredVersion $Version -Force' to install the required modules." -ForegroundColor Red
            $UserImput = Read-Host "Or try to install automatically, type y or n"
            if($UserImput -eq "y"){
                Write-Host "Please wait, an attempt will be made to install PSWriteHTML, this can take up to 30 seconds." -ForegroundColor Green
                $InstallJob_PSWH = Start-Job -ScriptBlock {Install-Module -Name PSWriteHTML -RequiredVersion 1.17.0 -Force -Scope CurrentUser}
                $InstallJob_PSWH | Wait-Job
		Import-Module PSWriteHTML
            }else {
                Write-Host "`nFurther execution of the function is terminated, in 5s" -ForegroundColor Red
		        Start-Sleep -seconds 6
                exit
            }
            if($InstallJob_PSWH.State -eq "Completed") {
                Write-Host "`nThe installation of PSWriteHTML seems to have been successful." -ForegroundColor Green
            }else {
                Write-Host "`nSomething went wrong, please install PSWriteHTML manually using the ' Install-Module -Name PSWriteHTML -RequiredVersion 1.17.0 -Force -Scope CurrentUser ' command.`nThe application will now be closed." -ForegroundColor Red
                Start-Sleep -Seconds 8
                exit
            }
        }elseif ($ModuleVersion -lt $Version) {
            Write-Host "PSWriteHTML $Version is required to run the Brocade Dashboard Report.`nRun 'Update-Module -Name PSWriteHTML -RequiredVersion $Version -Force' to update the required modules. " -ForegroundColor Yellow
		    Write-Host "`nFurther execution of the function is terminated, in 10s" -ForegroundColor Red
		    start-sleep -seconds 10
            exit
        }elseif ($ModuleVersion -gt $Version) {
            Write-Host "Attention!`nYour version is $ModuleVersion and therefore newer than the tested version $Version and this may cause display problems." -ForegroundColor Yellow
        }else {
            <# Action when all if and elseif conditions are false #>
            Write-Host "The check of the prerequisites for starting the function was successful." -ForegroundColor Green
		    start-sleep -seconds 1
        }
    }
    process{
        Write-Debug -Message "Func Open_Brocade_Dashboard |$(Get-Date)`n "
        $DeviceCredantails = GET_DeviceCredantials
        $DCounter=$DeviceCredantails.Count
        $CDevice=0

        Write-Debug -Message "List of devices with access`n $DeviceCredantails `n`n"
        if($DeviceCredantail.Protocol -eq 'plink'){$Encrypted = Read-Host "Device Password: "}
        foreach ($DeviceCredantail in $DeviceCredantails) {

            Write-Host "Collect data from Device $($DeviceCredantail.id), please wait" -ForegroundColor Green
            Write-Progress -Activity "Checking Device" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
            $CDevice = $DeviceCredantail.id
            $PercentComplete = [int](($CDevice / $DCounter) * 100)
            Start-Sleep -Seconds 1
            <#----------------------- DataCollect ------------------#>
            <# Collect some information for the Hastable, which is used for Basic SwitchInfos #>
            $UserName = $DeviceCredantail.UserName
            $IPAddress = $DeviceCredantail.IPAddress
            if($DeviceCredantail.Protocol -eq 'plink'){
                Write-Debug -Message "Start with Plink `n $DeviceCredantail `n"
                $Encrypted = ConvertFrom-SecureString -SecureString $DeviceCredantail.Password -AsPlainText
                $FOS_CollectedDeviceInfo = plink $UserName@$IPAddress -pw $Encrypted -batch "firmwareshow && ipaddrshow && switchshow && porterrshow && portbuffershow && zoneshow"
            }else {
                Write-Debug -Message "Start with ssh `n $DeviceCredantail `n"
                $FOS_CollectedDeviceInfo = ssh $UserName@$IPAddress "firmwareshow && ipaddrshow && switchshow && porterrshow && portbuffershow && zoneshow"
            }

            Write-Debug -Message "List of devices with access`n $DeviceCredantail `n"

            <# The bottom line is used for testing/ debuging #>
            #$FOS_CollectedDeviceInfo = Get-Content -Path ".\sw1_col.txt"
            <#----------------------- DataCollect ------------------#>


            Write-Debug -Message "Call the Dashboard_MainFuncion |$(Get-Date)`n"
            Dashboard_MainFuncion -FOS_CollectedDeviceInfos $FOS_CollectedDeviceInfo
            Write-Debug -Message "Dashboard_MainFuncion, done |$(Get-Date)`n"
            Start-Sleep -Seconds 1
            Write-Host "Dashboard incoming, please wait..." -ForegroundColor Green
            Start-Sleep -Seconds 2
            Write-Debug -Message "call $Env:TEMP\Dashboard.html |$(Get-Date)`n"
            Start-Process -FilePath $Env:TEMP\Dashboard.html
            Write-Debug -Message "Dashboard $($DeviceCredantail.id) `n"
        }
    }
    end{
        Write-Debug -Message "Func Open_Brocade_Dashboard, done |$(Get-Date)`n "
        #region CleanUp
        Write-Debug -Message "Cleaup all FOS* Variables Global |$(Get-Date)`n "
        Clear-Variable -Name Encrypted
        Clear-Variable FOS* -Scope Global;
        #endregion
    }
}

