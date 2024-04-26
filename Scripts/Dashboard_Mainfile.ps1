
# there a lot of "errors" in combination with substring Parameter, thats why "silentlycontinue"
$ErrorActionPreference="SilentlyContinue"
$DebugPreference="SilentlyContinue"

function Dashboard_MainFuncion {

    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
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
        $FOS_ZoningInfo = GET_ZoneDetails |Select-Object -Skip 2
        $FOS_SwBasicInfosold = $FOS_UniqueSwitchInfo[1]
    }else {
        <# Action when all if and elseif conditions are false #>
        Write-Debug "$FOS_SwBasicInfosold is equal $($FOS_UniqueSwitchInfo[1])" -ForegroundColor Green
    }
    <#------------------- Zoning -----------------------#>
    #endregion

    #region HTML - Creation
    Dashboard -Name "Brocade Testboard" -FilePath $Env:TEMP\Dashboard.html {
    Tab -Name "Info of $($FOS_UniqueSwitchInfo[0])" -IconSolid apple-alt -IconColor RedBerry {
            Section -Name "More Info 1" -Invisible {
                Section -Name "Basic Information" {
                    Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_BasicSwitchInfo
                }
                Section -Name "FID Information" {
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
        <#
        Tab -Name "Placeholder" {

        }
    #>
    }
}

function Open_Brocade_Dashboard {

    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    [CmdletBinding()]
    param (

    )
    [string]$Version="1.17.0"
    begin{
            $RequiredModule = Get-Module -ListAvailable -Name PSReadLine | Sort-Object -Property Version -Descending | Select-Object -First 1
            $ModuleVersion = "$($RequiredModule.Version)" #.Major)" + "." + "#$($RequiredModule.Version.Minor)"
            if ($ModuleVersion -eq ".")  {
                Write-Host "PSWriteHTML $Version or higher is required to run the Brocade Dashboard Report.`nRun 'Install-Module -Name PSWriteHTML -RequiredVersion $Version -Force' to install the required modules.`nFurther execution of the function is terminated." -ForegroundColor Red
                exit
            }elseif ($ModuleVersion -lt $Version) {
                Write-Host "PSWriteHTML $Version is required to run the Brocade Dashboard Report.`nRun 'Update-Module -Name PSWriteHTML -RequiredVersion $Version -Force' to update the required modules.`nFurther execution of the function is terminated. " -ForegroundColor Yellow
                exit
            }else {
                <# Action when all if and elseif conditions are false #>
                Write-Host "Something runs wrong.`nFurther execution of the function is terminated." -ForegroundColor Red
                exit
            }
    }

    Write-Debug -Message "Func Open_Brocade_Dashboard |$(Get-Date)`n "
    $DeviceCredantails = GET_DeviceCredantials

    Write-Debug -Message "List of devices with access`n $DeviceCredantails `n`n"

    foreach ($DeviceCredantail in $DeviceCredantails) {

        Write-Host "Collect data from Device $($DeviceCredantails.id), please wait" -ForegroundColor Green
        Start-Sleep -Seconds 1.5
        <#----------------------- DataCollect ------------------#>
        <# Collect some information for the Hastable, which is used for Basic SwitchInfos
        if($Credantails.Protocol -eq 'plink'){
            $FOS_CollectedDeviceInfo = plink $Credantails.FOS_UserName@$Credantails.FOS_DeviceIPADDR -pw $Credantails.FOSCredPW -batch "firmwareshow && ipaddrshow && lscfg --show -n && switchshow && porterrshow && portbuffershow"
        }else {
            $FOS_CollectedDeviceInfo = ssh $Credantails.FOS_UserName@$Credantails.FOS_DeviceIPADDR "firmwareshow && ipaddrshow && lscfg --show -n && switchshow && porterrshow && portbuffershow"
        }
        #>

        Write-Debug -Message "List of devices with access`n $DeviceCredantail `n"

        <# The bottom line is used for testing/ debuging #>
        $FOS_CollectedDeviceInfo = Get-Content -Path ".\sw2_col.txt"
        <#----------------------- DataCollect ------------------#>


        Write-Debug -Message "Call the Dashboard_MainFuncion |$(Get-Date)`n"
        Dashboard_MainFuncion -FOS_CollectedDeviceInfos $FOS_CollectedDeviceInfo
        Start-Sleep -Seconds 1.5
        Write-Host "Dashboard incoming, please wait" -ForegroundColor Blue
        Start-Sleep -Seconds 2
        Invoke-Item -Path $Env:TEMP\Dashboard.html
        Write-Debug -Message "Dashboard $($DeviceCredantail.id) `n"
    }
    Write-Debug -Message "Func Open_Brocade_Dashboard, done |$(Get-Date)`n "
}


#endregion
#region CleanUp
Write-Debug -Message "Cleaup all FOS* Variables Global |$(Get-Date)`n "
#Clear-Variable FOS* -Scope Global;
#endregion