
# there a lot of "errors" in combination with substring Parameter, thats why "silentlycontinue"
$ErrorActionPreference="SilentlyContinue"
$DebugPreference="Continue"

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
$FOS_SwBasicInfos =[ordered]@{}
<#----- Array Unique information of the switchports ----#>
$FOS_SwBasicPortDetails=@()
$FOS_usedPorts =@()
<#----- Array Unique information of the switch used at Porterrshow ----#>
$FOS_usedPortsfiltered =@()
<#----- Array Unique information of the switch used at portbuffershow ----#>
$FOS_pbs =@()
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
$FOS_advInfo = Get-Content -Path ".\ip_vers.txt"
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

$FOS_LoSw_CFG = (($FOS_advInfo | Select-String -Pattern 'FID:\s(\d+)$','SwitchType:\s(\w+)$','DomainID:\s(\d+)$','SwitchName:\s(.*)$','FabricName:\s(\w+)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)',''

$FOS_LoSwAdd_CFG = ((($FOS_advInfo | Select-String -Pattern '\D\((\w+)\)$','switchWwn:\s(.*)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)','').Trim()

$FOS_SwBasicInfos.Add('Swicht Name',$FOS_LoSw_CFG[3])
$FOS_SwBasicInfos.Add('Active ZonenCFG',$FOS_LoSwAdd_CFG[1].Trim('( )'))
$FOS_SwBasicInfos.Add('FabricName',$FOS_LoSw_CFG[4])
$FOS_SwBasicInfos.Add('DomainID',$FOS_LoSw_CFG[2])
$FOS_SwBasicInfos.Add('SwitchType',$FOS_LoSw_CFG[1])
$FOS_SwBasicInfos.Add('Switch WWN',$FOS_LoSwAdd_CFG[0])
$FOS_SwBasicInfos.Add('Fabric ID:',$FOS_LoSw_CFG[0])
<#----------- Logical Switch/ FID Infos -----------#>
#endregion

#region Porterrshow

$FOS_InfoCount = $FOS_advInfo.count
0..$FOS_InfoCount |ForEach-Object {
    # Pull only the effective ZoneCFG back into ZoneList
    if($FOS_advInfo[$_] -match '^\s+frames'){
        $FOS_advInfoTemp = $FOS_advInfo |Select-Object -Skip $_
        $FOS_perrsh_temp = $FOS_advInfoTemp |Select-Object -Skip 2
        #break
    }
}

foreach ($FOS_port in $FOS_perrsh_temp){
    #create a var and pipe some objects in
    $FOS_PortErr = "" | Select-Object Port,frames_tx,frames_rx,enc_in,crc_err,crc_g_eof,too_shrt,too_long,bad_eof,enc_out,disc_c3,link_fail,loss_sync,loss_sig,f_rejected,f_busied,c3timeout_tx,c3timeout_rx,psc_err,uncor_err
    #select the ports
    [Int16]$FOS_PortErr.Port = (($FOS_port |Select-String -Pattern '(\d+:)' -AllMatches).Matches.Value).Trim(':')
    
    #check if the port is "active", if it is fill the objects
    foreach($FOS_usedPortstemp in $FOS_usedPorts){
        if($FOS_PortErr.Port -eq $FOS_usedPortstemp){
        $FOS_PortErr.frames_tx = ($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[1]
        $FOS_PortErr.frames_rx = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[2])
        $FOS_PortErr.enc_in = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[3])
        $FOS_PortErr.crc_err = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[4])
        $FOS_PortErr.crc_g_eof = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[5])
        $FOS_PortErr.too_shrt = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[6])
        $FOS_PortErr.too_long = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[7])
        $FOS_PortErr.bad_eof = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[8])
        $FOS_PortErr.enc_out = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[9])
        $FOS_PortErr.disc_c3 = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[10])
        $FOS_PortErr.link_fail = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[11])
        $FOS_PortErr.loss_sync = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[12])
        $FOS_PortErr.loss_sig = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[13])
        $FOS_PortErr.f_rejected = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[14])
        $FOS_PortErr.f_busied = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[15])
        $FOS_PortErr.c3timeout_tx = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[16])
        $FOS_PortErr.c3timeout_rx = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[17])
        $FOS_PortErr.psc_err = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[18])
        $FOS_PortErr.uncor_err = (($FOS_port |Select-String -Pattern '(\d+\.\d\w|\d+)' -AllMatches).Matches.Value[19])
        $FOS_usedPortsfiltered += $FOS_PortErr
        }
    }
}
<#------------------- Porterrshow -----------------------#>
#endregion

#region Portbuffershow

$FOS_InfoCount = $FOS_advInfo.count
0..$FOS_InfoCount |ForEach-Object {
    # Pull only the effective ZoneCFG back into ZoneList
    if($FOS_advInfo[$_] -match 'Buffers$'){
        $FOS_pbs_temp = $FOS_advInfo |Select-Object -Skip $_
        $FOS_Temp_var = $FOS_pbs_temp |Select-Object -Skip 2
       
    }
}

foreach ($FOS_thisLine in $FOS_Temp_var) {
    #create a var and pipe some objects in and fill them with some data
    $FOS_PortBuff = "" | Select-Object Port,Type,Mode,Max_Resv,Tx,Rx,Usage,Buffers,Distance,Buffer
    $FOS_PortBuff.Port = ($FOS_thisLine |Select-String -Pattern '^\s+(\d+)' -AllMatches).Matches.Groups.Value[1]
    $FOS_PortBuff.Type = ($FOS_thisLine |Select-String -Pattern '([EFGLU])' -AllMatches).Matches.Groups.Value[1]
    $FOS_PortBuff.LX_Mode = ($FOS_thisLine |Select-String -Pattern '(LE|LD|L0|LS)' -AllMatches).Matches.Groups.Value[1]
    $FOS_PortBuff.Max_Resv = ($FOS_thisLine |Select-String -Pattern '(\d+)\s+(\d+\(|-\s\()' -AllMatches).Matches.Groups.Value[1]
    $FOS_PortBuff.Tx = ($FOS_thisLine |Select-String -Pattern '(\d+\(\d+\)|\d\(\s\d+\)|-\s\(\s\d+\)|-\s\(\s+\d+\)|-\s\(\d+\)|-\s\(\s+-\s+\))' -AllMatches).Matches.Groups.Value[1]
    $FOS_PortBuff.Rx = ($FOS_thisLine |Select-String -Pattern '(\d+\(\d+\)|\d\(\s\d+\)|-\s\(\s\d+\)|-\s\(\s+\d+\)|-\s\(\d+\)|-\s\(\s+-\s+\))' -AllMatches).Matches.Value[1]
    $FOS_PortBuff.Usage = ($FOS_thisLine |Select-String -Pattern '\)\s+(\d+)\s+' -AllMatches).Matches.Groups.Value[1]
    $FOS_PortBuff.Buffers = ($FOS_thisLine |Select-String -Pattern '\)\s+(\d+)\s+(\d+|-)' -AllMatches).Matches.Groups.Value[2]
    $FOS_PortBuff.Distance = ($FOS_thisLine |Select-String -Pattern '\d\s+(\d+|-)\s+(\d+km|\<\d+km|-)' -AllMatches).Matches.Groups.Value[2]
    $FOS_PortBuff.Buffer = ($FOS_thisLine |Select-String -Pattern '\s+(\d+)$' -AllMatches).Matches.Groups.Value[1]
    $FOS_pbs += $FOS_PortBuff

}
<#------------------- Portbuffershow -----------------------#>
#endregion

#region Zoning
$FOS_ZoningInfo = Get-Content -Path ".\zone_det.txt" |Select-Object -Skip 7
$FOS_ZoneOverview=@()
foreach ($FOS_ZoneLine in $FOS_ZoningInfo){
    $FOS_Zone = "" | Select-Object Name,WWPN,Alias
    if($FOS_ZoneLine -eq (($FOS_ZoneLine |Select-String -Pattern '\s+([0-9a-f:]{23})\s+(\b\w+\b)$' -AllMatches).Matches.Value)){
        $FOS_Zone.WWPN = ($FOS_ZoneLine |Select-String -Pattern '([0-9a-f:]{23})\s+(\b\w+\b)$' -AllMatches).Matches.Groups.Value[1]
        $FOS_Zone.Alias = ($FOS_ZoneLine |Select-String -Pattern '([0-9a-f:]{23})\s+(\b\w+\b)$' -AllMatches).Matches.Groups.Value[2]
        Write-Host $FOS_Zone.WWPN '->' $FOS_Zone.Alias -ForegroundColor Green
    }else {
        <# Action when all if and elseif conditions are false #>
        $FOS_Zone.Name = (($FOS_ZoneLine |Select-String -Pattern '(\b\w+\b)$' -AllMatches).Matches.Value).Trim()
        Write-Host $FOS_Zone.Name -ForegroundColor red
    }
    $FOS_ZoneOverview += $FOS_Zone
}
<#------------------- Zoning -----------------------#>
#endregion


#region HTML - Creation
Dashboard -Name "Brocade Testboard" -FilePath $Env:TEMP\Dashboard.html {
    Tab -Name "Info of $($FOS_SwBasicInfos[0])" {
        Section -Name "More Info 1" -Invisible {
            Section -Name "Basic Information" {
                Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_SwGeneralInfos
            }
            Section -Name "FID Information" {
                Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_SwBasicInfos
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
                Table -HideFooter -DataTable $FOS_pbs {
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
                Table -HideFooter -DataTable $FOS_usedPortsfiltered{
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
                Table -HideFooter -DisablePaging -DataTable $FOS_ZoneOverview
            }
        }
    }
     <# 
    Tab -Name "Placeholder" {

    }
    Tab -Name "Placeholder" {

    }
 #>   
} -Show

#endregion

#region CleanUp
#Clear-Variable FOS* -Scope Global;
#endregion
