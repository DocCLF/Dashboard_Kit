

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

        switch (($FOS_MainInformation | Select-String -Pattern 'switchType:\s+(\d.*)$' |ForEach-Object {$_.Matches.Groups[1].Value})) {
            {$_ -like "109*"}  { $FOS_SwHw = "Brocade 6510" }
            {$_ -like "118*"}  { $FOS_SwHw = "Brocade 6505" }
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

    }
    
    process {
        Write-Debug -Message "Process Func GET_BasicSwitchInfos |$(Get-Date)` "

        # add more Basic Infos of the switch to the Hashtable
        $FOS_SwGeneralInfos.Add('Brocade Product Name',$FOS_SwHw)

        foreach ($lineUp in $FOS_MainInformation) {
            if($lineUp -match '^Index'){break}
            $FOS_SwGeneralInfos.Add('Ethernet IP Address',(($lineUp| Select-String -Pattern 'Ethernet IP Address:\s+([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Ethernet Subnet mask',(($lineUp| Select-String -Pattern 'Ethernet Subnet mask:\s+([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Gateway IP Address',(($lineUp| Select-String -Pattern 'Gateway IP Address:\s+([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('DHCP',((($lineUp| Select-String -Pattern '^DHCP:\s(\w+)$' -AllMatches).Matches.Groups[1].Value)))
            $FOS_SwGeneralInfos.Add('Switch State',(($lineUp| Select-String -Pattern 'switchState:\s+(.*)$').Matches.Groups[1].Value))
            $FOS_SwGeneralInfos.Add('Switch Role',(($lineUp| Select-String -Pattern 'switchRole:\s+(.*)$').Matches.Groups[1].Value))
        }
        
    }
    
    end {
        Write-Debug -Message "End Func GET_BasicSwitchInfos |$(Get-Date)` "
        Write-Debug -Message "return $FOS_SwGeneralInfos ` $(Get-Date)` "
        return $FOS_SwGeneralInfos
    }
}