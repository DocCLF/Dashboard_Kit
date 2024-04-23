

function GET_UniqueSwitchInfos {
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
    param (
        [Parameter(Mandatory)]
        [System.Object]$FOS_MainInformation
    )
    begin{
        Write-Debug -Message "Start Func GET_UniqueSwitchInfos |$(Get-Date)` "
        <# Create an ordered hashtable #>
        $FOS_SwBasicInfos =[ordered]@{}
    }
    process{
        <# collect the information with the help of regex pattern and remove the blanks with the help of replace and trim #>
        $FOS_LoSw_CFG = (($FOS_MainInformation | Select-String -Pattern 'FID:\s(\d+)$','SwitchType:\s(\w+)$','DomainID:\s(\d+)$','SwitchName:\s(.*)$','FabricName:\s(\w+)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)',''

        $FOS_LoSwAdd_CFG = ((($FOS_MainInformation | Select-String -Pattern '\D\((\w+)\)$','switchWwn:\s(.*)$' -AllMatches).Matches.Value) -replace '^(\w+:\s)','').Trim()

        <# add the values to the hashtable #>
        $FOS_SwBasicInfos.Add('Swicht Name',$FOS_LoSw_CFG[3])
        $FOS_SwBasicInfos.Add('Active ZonenCFG',$FOS_LoSwAdd_CFG[1].Trim('( )'))
        $FOS_SwBasicInfos.Add('FabricName',$FOS_LoSw_CFG[4])
        $FOS_SwBasicInfos.Add('DomainID',$FOS_LoSw_CFG[2])
        $FOS_SwBasicInfos.Add('SwitchType',$FOS_LoSw_CFG[1])
        $FOS_SwBasicInfos.Add('Switch WWN',$FOS_LoSwAdd_CFG[0])
        $FOS_SwBasicInfos.Add('Fabric ID:',$FOS_LoSw_CFG[0])
    }
    end{
        <# returns the hashtable for further processing, not mandatory but the safe way #>
        return $FOS_SwBasicInfos
        Write-Debug -Message "return $FOS_SwBasicInfos ` $(Get-Date)` "
        Write-Debug -Message "End Func GET_UniqueSwitchInfos |$(Get-Date)` "
    }
}