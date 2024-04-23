

function GET_BasicSwitchInfos {
    <#
    .SYNOPSIS
        Creates a hashtable with Basic information about the switch.
    .DESCRIPTION
        Use this Function to display basic information about the switch. 
        This function uses various FOS commands to provide the required information.
        FOS Commands are firmwareshow, ipaddrshow, lscfg --show -n, switchshow 
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        GET_BasicSwitchInfos -FOS_MainInformation $yourvarobject 
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$FOS_MainInformation
    )
    
    begin {

        Write-Debug -Message "Start Func GET_BasicSwitchInfos |$(Get-Date)` "

        <# Hashtable for BasicSwitch Info #>
        $FOS_SwGeneralInfos =[ordered]@{}

        <# Collect all needed Infos #>
        $FOS_FW_Info = ($FOS_advInfo | Select-String -Pattern '([v?][\d]\.[\d+]\.[\d]\w)$' -AllMatches).Matches.Value |Select-Object -Unique
        $FOS_IP_AddrCFG = ($FOS_advInfo | Select-String -Pattern '(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Value |Select-Object -Unique
        $FOS_DHCP_CFG = (($FOS_advInfo | Select-String -Pattern '^DHCP:\s(\w+)$' -AllMatches).Matches.Value |Select-Object -Unique).Trim('DHCP: ')
        $FOS_temp = ($FOS_advInfo | Select-String -Pattern 'switchType:\s(.*)$','switchState:\s(.*)$','switchRole:\s(.*)$' |ForEach-Object {$_.Matches.Groups[1].Value}).Trim()

        Write-Debug -Message "FOS-Version $FOS_FW_Info ` IP-CFG $FOS_IP_AddrCFG ` DHCP $FOS_DHCP_CFG ` Switch $FOS_temp ` $(Get-Date)` "

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
        
    }
    
    process {
        Write-Debug -Message "Process Func GET_BasicSwitchInfos |$(Get-Date)` "

        # add more Basic Infos of the switch to the Hashtable
        $FOS_SwGeneralInfos.Add('Brocade Product Name',$FOS_SwHw)
        $FOS_SwGeneralInfos.Add('FOS Version',$FOS_FW_Info)
        $FOS_SwGeneralInfos.Add('Ethernet IP Address',$FOS_IP_AddrCFG[0])
        $FOS_SwGeneralInfos.Add('Ethernet Subnet mask',$FOS_IP_AddrCFG[1])
        $FOS_SwGeneralInfos.Add('Gateway IP Address',$FOS_IP_AddrCFG[2])
        $FOS_SwGeneralInfos.Add('DHCP',$FOS_DHCP_CFG)
        $FOS_SwGeneralInfos.Add('Switch State',$FOS_StateTemp)
        $FOS_SwGeneralInfos.Add('Switch Role',$FOS_RoleTemp)
        
    }
    
    end {
        Write-Debug -Message "End Func GET_BasicSwitchInfos |$(Get-Date)` "
        Write-Debug -Message "return $FOS_SwGeneralInfos ` $(Get-Date)` "
        return $FOS_SwGeneralInfos
    }
}