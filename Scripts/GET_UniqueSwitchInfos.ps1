

function GET_UniqueSwitchInfos ($FOS_MainInformation) {
    <#
    .SYNOPSIS
    Creates a hashtable with unique information about the switch.

    .DESCRIPTION
    Use this Function to display unique information about the switch. 
    This function uses various FOS commands to provide the required information.
    FOS Commands are firmwareshow, ipaddrshow, lscfg --show -n, switchshow   

    .EXAMPLE
    $FOS_UniqueSwitchInfo = GET_UniqueSwitchInfos -FOS_MainInformation $FOS_advInfo

    $FOS_advInfo is a collection of the commands listed in the Description
        
    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.2.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
    #>

    $FOS_SwBasicInfos =[ordered]@{}

    $FOS_LoSw_CFG = (($FOS_MainInformation | Select-String -Pattern 'FID:\s(\d+)$','SwitchType:\s(\w+)$','DomainID:\s(\d+)$','SwitchName:\s(.*)$','FabricName:\s(\w+)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)',''

    $FOS_LoSwAdd_CFG = ((($FOS_MainInformation | Select-String -Pattern '\D\((\w+)\)$','switchWwn:\s(.*)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)','').Trim()

    $FOS_SwBasicInfos.Add('Swicht Name',$FOS_LoSw_CFG[3])
    $FOS_SwBasicInfos.Add('Active ZonenCFG',$FOS_LoSwAdd_CFG[1].Trim('( )'))
    $FOS_SwBasicInfos.Add('FabricName',$FOS_LoSw_CFG[4])
    $FOS_SwBasicInfos.Add('DomainID',$FOS_LoSw_CFG[2])
    $FOS_SwBasicInfos.Add('SwitchType',$FOS_LoSw_CFG[1])
    $FOS_SwBasicInfos.Add('Switch WWN',$FOS_LoSwAdd_CFG[0])
    $FOS_SwBasicInfos.Add('Fabric ID:',$FOS_LoSw_CFG[0])

    return $FOS_SwBasicInfos
}