
# there a lot of "errors" in combination with substring Parameter, thats why "silentlycontinue"
$ErrorActionPreference="SilentlyContinue"
$DebugPreference="SilentlyContinue"

#$Credantails = Device_Credantials

<#
$Proto=$Credantails.Protocol
$UserName =$Credantails.UserName
$Credantails.IPAddress |ForEach-Object {Write-Host "test $_"}
#>
#region Hashtables
<#--------- Hashtable for BasicSwitch Info ------------#>
$FOS_SwGeneralInfos =[ordered]@{}
<#----- Hashtable Unique information of the switch ----#>
#$FOS_SwBasicInfos =[ordered]@{}
<#----- Array Unique information of the switchports ----#>
$FOS_SwBasicPortDetails=@()
$FOS_usedPorts =@()
<#----- Array Unique information of the switch used at Porterrshow ----#>
#$FOS_usedPortsfiltered =@()
<#----- Array Unique information of the switch used at portbuffershow ----#>
#$FOS_pbs =@()
#endregion


<#--------------------Testarea maybe for later use -------------------#>
<# nothing included at the moment #>
<#---------------------------------------#>

#region DataCollect 
<# Collect some information for the Hastable, which is used for Basic SwitchInfos
if($Credantails.Protocol -eq 'plink'){
    $FOS_advInfo = plink $Credantails.FOS_UserName@$Credantails.FOS_DeviceIPADDR -pw $Credantails.FOSCredPW -batch "firmwareshow && ipaddrshow && lscfg --show -n && switchshow && porterrshow && portbuffershow"
}else {
    $FOS_advInfo = ssh $Credantails.FOS_UserName@$Credantails.FOS_DeviceIPADDR "firmwareshow && ipaddrshow && lscfg --show -n && switchshow && porterrshow && portbuffershow"
}
#>
$FOS_advInfo = Get-Content -Path ".\swSmal_col.txt"
<#----------------------- DataCollect ------------------#>
#endregion


#region Switchshow

# Collect all needed Infos
$FOS_FW_Info = ($FOS_advInfo | Select-String -Pattern '([v?][\d]\.[\d+]\.[\d]\w)$' -AllMatches).Matches.Value |Select-Object -Unique
$FOS_IP_AddrCFG = ($FOS_advInfo | Select-String -Pattern '(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Value |Select-Object -Unique
$FOS_DHCP_CFG = (($FOS_advInfo | Select-String -Pattern '^DHCP:\s(\w+)$' -AllMatches).Matches.Value |Select-Object -Unique).Trim('DHCP: ')
$FOS_temp = ($FOS_advInfo | Select-String -Pattern 'switchType:\s(.*)$','switchState:\s(.*)$','switchRole:\s(.*)$' |ForEach-Object {$_.Matches.Groups[1].Value}).Trim()

<# Make the product type understandable for people. ;) #>
if($FOS_temp[2] -like "1*"){
    # with VF jump in here
    switch ($FOS_temp[2]) {
        {$_ -like "170*"}  { $FOS_SwHw = "Brocade G610" }
        {$_ -like "162*"}  { $FOS_SwHw = "Brocade G620" }
        {$_ -like "183*"}  { $FOS_SwHw = "Brocade G620" }
        {$_ -like "173*"}  { $FOS_SwHw = "Brocade G630" }
        {$_ -like "184*"}  { $FOS_SwHw = "Brocade G630" }
        {$_ -like "178*"}  { $FOS_SwHw = "Brocade 7810 Extension Switch" }
        {$_ -like "181*"}  { $FOS_SwHw = "Brocade G720" }
        {$_ -like "189*"}  { $FOS_SwHw = "Brocade G730" }
        Default {$FOS_SwHw = "Unknown Type"}
    }
    $FOS_StateTemp =$FOS_temp[3]
    $FOS_RoleTemp =$FOS_temp[4]
}else {
    # else jump in here
    switch ($FOS_temp[1]) {
        {$_ -like "170*"}  { $FOS_SwHw = "Brocade G610" }
        {$_ -like "162*"}  { $FOS_SwHw = "Brocade G620" }
        {$_ -like "183*"}  { $FOS_SwHw = "Brocade G620" }
        {$_ -like "173*"}  { $FOS_SwHw = "Brocade G630" }
        {$_ -like "184*"}  { $FOS_SwHw = "Brocade G630" }
        {$_ -like "178*"}  { $FOS_SwHw = "Brocade 7810 Extension Switch" }
        {$_ -like "181*"}  { $FOS_SwHw = "Brocade G720" }
        {$_ -like "189*"}  { $FOS_SwHw = "Brocade G730" }
        Default {$FOS_SwHw = "Unknown Type"}
    }
    $FOS_StateTemp =$FOS_temp[2]
    $FOS_RoleTemp =$FOS_temp[3]
}


foreach($FOS_linebyLine in $FOS_advInfo){
        <# Only collect data up to the next section, marked by frames #>
        if($FOS_linebyLine -match '^\s+frames'){break}

        # add more Basic Infos of the switch to the Hashtable
        $FOS_SwGeneralInfos.Add('Brocade Product Name',$FOS_SwHw)
        $FOS_SwGeneralInfos.Add('FOS Version',$FOS_FW_Info)
        $FOS_SwGeneralInfos.Add('Ethernet IP Address',$FOS_IP_AddrCFG[0])
        $FOS_SwGeneralInfos.Add('Ethernet Subnet mask',$FOS_IP_AddrCFG[1])
        $FOS_SwGeneralInfos.Add('Gateway IP Address',$FOS_IP_AddrCFG[2])
        $FOS_SwGeneralInfos.Add('DHCP',$FOS_DHCP_CFG)
        $FOS_SwGeneralInfos.Add('Switch State',$FOS_StateTemp)
        $FOS_SwGeneralInfos.Add('Switch Role',$FOS_RoleTemp)
        
        
        # Build the Portsection of switchshow
        if($FOS_linebyLine -match '^\s+\d+'){
            $FOS_SWsh = "" | Select-Object Index,Port,Address,Media,Speed,State,Proto,PortConnect
            $FOS_SWsh.Index = $FOS_linebyLine.Substring(0,4).Trim()
            $FOS_SWsh.Port = $FOS_linebyLine.Substring(5,5).Trim()
            $FOS_SWsh.Address = $FOS_linebyLine.Substring(10,8).Trim()
            $FOS_SWsh.Media = $FOS_linebyLine.Substring(20,4).Trim()
            $FOS_SWsh.Speed = $FOS_linebyLine.Substring(25,5).Trim()
            $FOS_SWsh.State = $FOS_linebyLine.Substring(34,10).Trim()
            $FOS_SWsh.Proto = $FOS_linebyLine.Substring(45,4).Trim()
            $FOS_SWsh.PortConnect = $FOS_linebyLine.Substring(50).Trim()
            $FOS_SwBasicPortDetails += $FOS_SWsh
        }
        # if the Portnumber is not empty and there is a SFP pluged in, push the Port in the FOS_usedPorts array
        if(($FOS_SWsh.Port -ne "") -and ($FOS_SWsh.Media -eq "id")){$FOS_usedPorts += $FOS_SWsh.Port}
}
<#----------------------- Switchshow ------------------#>
#endregion


#region LogicalSwitch
<#----------- LogicalSwitch/ FID Infos -----------#>
<#----------- Unique information of the switch -----------#>
$FOS_UniqueSwitchInfo = GET_UniqueSwitchInfos -FOS_MainInformation $FOS_advInfo
<#----------- Logical Switch/ FID Infos -----------#>
#endregion

#region Porterrshow
$FOS_PortErrShow = GET_PortErrShowInfos -FOS_MainInformation $FOS_advInfo -FOS_GetUsedPorts $FOS_usedPorts
<#------------------- Porterrshow -----------------------#>
#endregion

#region Portbuffershow
$FOS_PortBuffershow = Get_PortbufferShowInfo -FOS_MainInformation $FOS_advInfo
<#------------------- Portbuffershow -----------------------#>
#endregion

#region Zoning
if($FOS_SwBasicInfosold -ne $FOS_UniqueSwitchInfo[1]){
    $FOS_ZoningInfo = GET_ZoneDetails |Select-Object -Skip 2
    $FOS_SwBasicInfosold = $FOS_UniqueSwitchInfo[1]
}else {
    <# Action when all if and elseif conditions are false #>
    Write-Host "$FOS_SwBasicInfosold is equal $($FOS_UniqueSwitchInfo[1])" -ForegroundColor Green
}
<#------------------- Zoning -----------------------#>
#endregion

#region HTML - Creation
Dashboard -Name "Brocade Testboard" -FilePath $Env:TEMP\Dashboard.html {
   Tab -Name "Info of $($FOS_UniqueSwitchInfo[0])" -IconSolid apple-alt -IconColor RedBerry {
        Section -Name "More Info 1" -Invisible {
            Section -Name "Basic Information" {
                Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_SwGeneralInfos
            }
            Section -Name "FID Information" {
                Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_UniqueSwitchInfo
            }
        }
        Section -Name "bluber" -Invisible{
            Section -Name "Basic Port Information" {
                New-HTMLChart{
                    New-ChartPie -Name "Available Ports" -Value $($FOS_SwBasicPortDetails.Count) -Color Green
                    New-ChartPie -Name "Used Ports" -Value $($FOS_usedPorts.count) -Color Red
                }
            }
            Section -Name "Used Port Speed Allocation" {
                New-HTMLChart{
                    New-ChartPie -Name "64G" -Value $(($FOS_SwBasicPortDetails |Where-Object {$_.Speed -eq "N64"}).count)
                    New-ChartPie -Name "32G" -Value $(($FOS_SwBasicPortDetails |Where-Object {$_.Speed -eq "N32"}).count)
                    New-ChartPie -Name "16G" -Value $(($FOS_SwBasicPortDetails |Where-Object {$_.Speed -eq "N16"}).count)
                    New-ChartPie -Name "8G" -Value $(($FOS_SwBasicPortDetails |Where-Object {$_.Speed -eq "N8"}).count)
                    New-ChartPie -Name "4G" -Value $(($FOS_SwBasicPortDetails |Where-Object {$_.Speed -eq "N4"}).count)
                }
            }
        }
        Section -Name "Port Info" -Invisible{
            Section -Name "Port Basic Show" -CanCollapse {
                Table -HideFooter -DataTable $FOS_SwBasicPortDetails{
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
                    #TableConditionalFormatting -Name 'disc_c3' -ComparisonType number -Operator gt -Value 200 -BackgroundColor LightGoldenrodYellow
                    #TableConditionalFormatting -Name 'disc_c3' -ComparisonType number -Operator gt -Value 400 -BackgroundColor OrangeRed
                    #TableConditionalFormatting -Name 'link_fail' -ComparisonType number -Operator gt -Value 3 -BackgroundColor LightGoldenrodYellow
                    #TableConditionalFormatting -Name 'link_fail' -ComparisonType number -Operator gt -Value 6 -BackgroundColor OrangeRed
                    #TableConditionalFormatting -Name 'loss_sig' -ComparisonType number -Operator gt -Value 1 -BackgroundColor LightGoldenrodYellow
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
} -Show

#endregion

#region CleanUp
Clear-Variable FOS* -Scope Global;
#endregion
