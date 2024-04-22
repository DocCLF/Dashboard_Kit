

function GET_PortErrShowInfos {
    <#
    .SYNOPSIS
    Displays a port error summary.

    .DESCRIPTION
    Use this command to display an error summary for a port or a range of ports. Counts are reported on frames transmitted by the port (Tx) or on frames received by the port (Rx). 
    The display contains one output line per port. Numeric values exceeding 999 are displayed in units of thousands (k), millions (m), or giga (g) if indicated.
    You can identify a single port to be configured by its port number or by its port index number in decimal or hexadecimal format. 
    Port ranges are supported with port numbers, index numbers (decimal or hexadecimal) or by specifying a slot or a slot range. 
    Use switchShow for a listing of valid ports, slots, and port index numbers. When used without operands, this command displays error summary for all ports on the switch.    

    For more information use the link below
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands/portErrShow.html
    
    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.2.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands/portErrShow.html
    #>

    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [System.Object]$FOS_MainInformation,
        [Parameter(Mandatory,ValueFromPipeline)]
        [int]$FOS_GetUsedPorts
    )

    begin{
        Write-Debug -Message "Begin GET_PortErrShowInfos |$(Get-Date)"
        Write-Debug -Message " ` counted MainInformation $($FOS_MainInformation.count) - UsedPorts: $FOS_GetUsedPorts ` "
        <# Create a Array for the unique information of the switch used at Porterrshow #>
        $FOS_PortErrShowfiltered =@()

        $FOS_InfoCount = $FOS_MainInformation.count
        Write-Debug -Message " ` $FOS_InfoCount ` "
        0..$FOS_InfoCount |ForEach-Object {
            # Pull only the effective ZoneCFG back into ZoneList
            if($FOS_MainInformation[$_] -match '^\s+frames'){
                $FOS_advInfoTemp = $FOS_MainInformation |Select-Object -Skip $_
                $FOS_perrsh_temp = $FOS_advInfoTemp |Select-Object -Skip 2   
            }
        }
    }
    process{
        Write-Debug -Message "Start of Process from GET_PortErrShowInfos |$(Get-Date) ` "
        foreach ($FOS_port in $FOS_perrsh_temp){
            #create a var and pipe some objects in
            $FOS_PortErr = "" | Select-Object Port,frames_tx,frames_rx,enc_in,crc_err,crc_g_eof,too_shrt,too_long,bad_eof,enc_out,disc_c3,link_fail,loss_sync,loss_sig,f_rejected,f_busied,c3timeout_tx,c3timeout_rx,psc_err,uncor_err
            #select the ports
            [Int16]$FOS_PortErr.Port = (($FOS_port |Select-String -Pattern '(\d+:)' -AllMatches).Matches.Value).Trim(':')
            
            #check if the port is "active", if it is fill the objects
            foreach($FOS_usedPortstemp in $FOS_GetUsedPorts){
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
                $FOS_PortErrShowfiltered += $FOS_PortErr
                }
            }
        }
        Write-Debug -Message " ` $FOS_PortErrShowfiltered ` "
    }
    end{
        Write-Debug -Message " `End GET_PortErrShowInfos |$(Get-Date) ` "
        return $FOS_PortErrShowfiltered
    }
}