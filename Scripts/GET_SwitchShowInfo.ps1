

function GET_SwitchShowInfo {
    <#
    .SYNOPSIS
        Get switch and port status.
    .DESCRIPTION
        Use this command to display switch, blade, and port status information. Output may vary depending on the switch model.
    .NOTES
        
    .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.2.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands/switchShow_921.html
    .EXAMPLE
        GET_BasicSwitchInfos -FOS_MainInformation $yourvarobject
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$FOS_MainInformation
    )
    
    begin {

        Write-Debug -Message "Start Func GET_SwitchShowInfo |$(Get-Date)` "

        <#----- Array for information of the switchports ----#>
        $FOS_SwBasicPortDetails=@()
        
    }
    
    process {

        Write-Debug -Message "Process Func GET_SwitchShowInfo |$(Get-Date)` "

        foreach($FOS_linebyLine in $FOS_MainInformation){

            <# Only collect data up to the next section, marked by frames #>
            if($FOS_linebyLine -match '^\s+frames'){break}
    
            # Build the Portsection of switchshow
            if($FOS_linebyLine -match '^\s+\d+'){
                $FOS_SWsh = "" | Select-Object Index,Port,Address,Media,Speed,State,Proto,PortConnect
                <# Port index is a number between 0 and the maximum number of supported ports on the platform. The port index identifies the port number relative to the switch. #>
                $FOS_SWsh.Index = $FOS_linebyLine.Substring(0,4).Trim()
                <# Port number; 0-15, 0-31, or 0-63. #>
                $FOS_SWsh.Port = $FOS_linebyLine.Substring(5,5).Trim()
                <# The 24-bit Address Identifier. #>
                $FOS_SWsh.Address = $FOS_linebyLine.Substring(10,8).Trim()
                <# Media types means module types #>
                $FOS_SWsh.Media = $FOS_linebyLine.Substring(20,4).Trim()
                <# The speed of the port. #>
                $FOS_SWsh.Speed = $FOS_linebyLine.Substring(25,5).Trim()
                <# Port state information #>
                $FOS_SWsh.State = $FOS_linebyLine.Substring(34,10).Trim()
                <# Protocol support by GbE port. #>
                $FOS_SWsh.Proto = $FOS_linebyLine.Substring(45,4).Trim()
                <# WWPN or other Infos #>
                $FOS_SWsh.PortConnect = $FOS_linebyLine.Substring(50).Trim()
                $FOS_SwBasicPortDetails += $FOS_SWsh
            }
        }

    }
    
    end {

        <# returns the hashtable for further processing, not mandatory but the safe way #>
        return $FOS_SwBasicPortDetails
        Write-Debug -Message "return $FOS_SwBasicPortDetails ` $(Get-Date)` "
        Write-Debug -Message "End Func GET_SwitchShowInfo |$(Get-Date)` "
        
    }
}