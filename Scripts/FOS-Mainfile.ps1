
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
#endregion


<#--------------------Test maybe for later use -------------------#>
# the line below is only a test maybe usfull for later to check if one or more FIDs online at one switch
$FOS_LoSw_CFG = (($FOS_advInfo | Select-String -Pattern 'FID:\s(\d+)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)',''
<#---------------------------------------#>


#region Switchshow

<# Collect some information for the Hastable, which is used for Basic SwitchInfos
if($Credantails.Protocol -eq 'plink'){
    $FOS_advInfo = plink $Credantails.FOS_UserName@$Credantails.FOS_DeviceIPADDR -pw $Credantails.FOSCredPW -batch "firmwareshow && ipaddrshow && lscfg --show -n && switchshow && porterrshow"
   # $FOS_swsh_temp = plink $FOS_UserName@$FOS_DeviceIPADDR -pw $FOSCredPW -batch "switchshow"
}else {

    $FOS_advInfo = ssh $Credantails.FOS_UserName@$Credantails.FOS_DeviceIPADDR "firmwareshow && ipaddrshow && lscfg --show -n && switchshow && porterrshow"
}
#>
$FOS_advInfo = Get-Content -Path ".\ip_vers.txt" #|Select-Object -Skip 2
# Select all needed Infos
$FOS_FW_Info = ($FOS_advInfo | Select-String -Pattern '([v?][\d]\.[\d+]\.[\d]\w)$' -AllMatches).Matches.Value |Select-Object -Unique
$FOS_IP_AddrCFG = ($FOS_advInfo | Select-String -Pattern '(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Value |Select-Object -Unique
$FOS_DHCP_CFG = (($FOS_advInfo | Select-String -Pattern '^DHCP:\s(\w+)$' -AllMatches).Matches.Value |Select-Object -Unique).Trim('DHCP: ')

#$FOS_pbs_temp = plink insight@192.168.107.40 -pw Insight0Mon -batch "portbuffershow" 
#$FOS_swsh_temp = Get-Content -Path ".\swsh.txt"
$FOS_SwBasicPortDetails=@()
$FOS_usedPorts =@()
foreach($FOS_linebyLine in $FOS_advInfo){
        if($FOS_linebyLine -match '^\s+frames'){break}
        # select some Basic Switch Infos
        $FOS_temp += Select-String -InputObject $FOS_linebyLine -Pattern 'switchType:\s(.*)$','switchState:\s(.*)$','switchRole:\s(.*)$' |ForEach-Object {$_.Matches.Groups[1].Value}

        # Split FOS_temp in parts, the regex \s means any whitespace character, + means one or more
        $FOS_SwInfo = $FOS_temp.Trim() -split ("\s+")

        # make the Switch Typ readable without using google ;)
        if($FOS_SwInfo[0] -ne ""){
            switch ($FOS_SwInfo[0]) {
                {$_ -like "170*"}  { $FOS_SwHw = "Brocade G610" }
                {$_ -like "162*"}  { $FOS_SwHw = "Brocade G620" }
                {$_ -like "183*"}  { $FOS_SwHw = "Brocade G620" }
                {$_ -like "173*"}  { $FOS_SwHw = "Brocade G630" }
                {$_ -like "184*"}  { $FOS_SwHw = "Brocade G630" }
                {$_ -like "178*"}  { $FOS_SwHw = "Brocade 7810 Extension Switch" }
                {$_ -like "181*"}  { $FOS_SwHw = "Brocade G720" }
                {$_ -like "189*"}  { $FOS_SwHw = "Brocade G730" }
                Default {$FOS_SwHw = $FOS_SwInfo[0]}
            }
        }
        
        # add more Basic Infos of the switch to the Hashtable
        $FOS_SwGeneralInfos.Add('Brocade Product Name',$FOS_SwHw)
        $FOS_SwGeneralInfos.Add('FOS Version',$FOS_FW_Info)
        $FOS_SwGeneralInfos.Add('Ethernet IP Address',$FOS_IP_AddrCFG[0])
        $FOS_SwGeneralInfos.Add('Ethernet Subnet mask',$FOS_IP_AddrCFG[1])
        $FOS_SwGeneralInfos.Add('Gateway IP Address',$FOS_IP_AddrCFG[2])
        $FOS_SwGeneralInfos.Add('DHCP',$FOS_DHCP_CFG)
        $FOS_SwGeneralInfos.Add('Switch State',$FOS_SwInfo[1])
        $FOS_SwGeneralInfos.Add('Switch Role',$FOS_SwInfo[2])
        
        
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


#region Logical Switch/ FID Infos
<#----------- Unique information of the switch -----------#>
#Clear-Variable -Name FOS_advInfo
#$FOS_advInfo = Get-Content -Path ".\lscfg.txt"
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

#$FOS_perrsh_temp = Get-Content -Path ".\porteersh.txt" |Select-Object -Skip 2
$FOS_usedPortsfiltered =@()
$FOS_PortErrRegex = ':\s+(\d+.\d\w)\s+(\d+.\d\w)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)'
foreach ($FOS_port in $FOS_perrsh_temp){
    #create a var and pipe some objects in
    $FOS_PortErr = "" | Select-Object Port,frames_tx,frames_rx,enc_in,crc_err,crc_g_eof,too_shrt,too_long,bad_eof,enc_out,disc_c3,link_fail,loss_sync,loss_sig,f_rejected,f_busied,c3timeout_tx,c3timeout_rx,psc_err,uncor_err
    #select the ports
    [Int16]$FOS_PortErr.Port = (($FOS_port |Select-String -Pattern '(\d+:)' -AllMatches).Matches.Value).Trim(':')
    #[int]$FOS_PortErr.disc_c3 = $FOS_port.Substring(69,6).Trim()
    #check if the port is "active", if it is fill the objects
    foreach($FOS_usedPortstemp in $FOS_usedPorts){
        if($FOS_PortErr.Port -eq $FOS_usedPortstemp){
        $FOS_PortErr.frames_tx = ($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[1]
        $FOS_PortErr.frames_rx = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[2])
        $FOS_PortErr.enc_in = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[3])
        $FOS_PortErr.crc_err = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[4])
        $FOS_PortErr.crc_g_eof = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[5])
        $FOS_PortErr.too_shrt = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[6])
        $FOS_PortErr.too_long = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[7])
        $FOS_PortErr.bad_eof = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[8])
        $FOS_PortErr.enc_out = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[9])
        $FOS_PortErr.disc_c3 = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[10])
        $FOS_PortErr.link_fail = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[11])
        $FOS_PortErr.loss_sync = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[12])
        $FOS_PortErr.loss_sig = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[13])
        $FOS_PortErr.f_rejected = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[14])
        $FOS_PortErr.f_busied = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[15])
        $FOS_PortErr.c3timeout_tx = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[16])
        $FOS_PortErr.c3timeout_rx = (($FOS_port |Select-String -Pattern $FOS_PortErrRegex -AllMatches).Matches.Groups.Value[17])
        $FOS_PortErr.psc_err = (($FOS_port |Select-String -Pattern '\s+(.{6})\s+\d+$' -AllMatches).Matches.Groups.Value[1]).Trim()
        $FOS_PortErr.uncor_err = (($FOS_port |Select-String -Pattern '(\d+)$' -AllMatches).Matches.Groups.Value[1])
        $FOS_usedPortsfiltered += $FOS_PortErr
        }
    }
}
<#------------------- Porterrshow -----------------------#>
#endregion

#region Portbuffershow
# $test = ssh admin@192.168.249.81 "portbuffershow" 
$FOS_Temp_var = $FOS_pbs_temp |Select-Object -Skip 3
#$FOS_pbs_temp = plink insight@192.168.107.40 -pw Insight0Mon -batch "portbuffershow" 
$FOS_pbs_temp = Get-Content -Path ".\pbs_l.txt"
$FOS_Temp_var = $FOS_pbs_temp |Select-Object -Skip 3
$FOS_pbs =@()
foreach ($FOS_thisLine in $FOS_Temp_var) {
    #create a var and pipe some objects in and fill them with some data
    $FOS_PortBuff = "" | Select-Object Port,Type,Mode,Max_Resv,Tx,Rx,Usage,Buffers,Distance,Buffer
    $FOS_PortBuff.Port = $FOS_thisLine.Substring(0,4).Trim()
    $FOS_PortBuff.Type = $FOS_thisLine.Substring(11,4).Trim()
    $FOS_PortBuff.LX_Mode = $FOS_thisLine.Substring(17,4).Trim()
    $FOS_PortBuff.Max_Resv = $FOS_thisLine.Substring(27,7).Trim()
    $FOS_PortBuff.Tx = $FOS_thisLine.Substring(36,14).Trim()
    $FOS_PortBuff.Rx = $FOS_thisLine.Substring(50,14).Trim()
    $FOS_PortBuff.Usage = $FOS_thisLine.Substring(67,6).Trim()
    $FOS_PortBuff.Buffers = $FOS_thisLine.Substring(75,7).Trim()
    $FOS_PortBuff.Distance = $FOS_thisLine.Substring(85,6).Trim(" ","-")
    $FOS_PortBuff.Buffer = $FOS_thisLine.Substring(95,6).Trim()
    $FOS_pbs += $FOS_PortBuff

}
<#------------------- Portbuffershow -----------------------#>
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
                    TableConditionalFormatting -Name 'link_fail' -ComparisonType number -Operator gt -Value 5 -BackgroundColor LightGoldenrodYellow
                    TableConditionalFormatting -Name 'loss_sig' -ComparisonType number -Operator gt -Value 5 -BackgroundColor LightGoldenrodYellow
                }
            }
        }
    }
 <#   
    Tab -Name "Info of Switch Name 2" {

    }
    Tab -Name "Info of Switch Name 3" {

    }
    Tab -Name "Info of Switch Name 4" {

    }
 #>   
} -Show

#endregion


#region CleanUp
#Clear-Variable FOS* -Scope Global;
#endregion
