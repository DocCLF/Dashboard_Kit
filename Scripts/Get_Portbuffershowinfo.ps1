


function Get_PortbufferShowInfo ($FOS_MainInformation) {
    $FOS_pbs =@()
    $FOS_InfoCount = $FOS_MainInformation.count
    0..$FOS_InfoCount |ForEach-Object {
        # Pull only the effective ZoneCFG back into ZoneList
        if($FOS_MainInformation[$_] -match 'Buffers$'){
            $FOS_pbs_temp = $FOS_MainInformation |Select-Object -Skip $_
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
    return $FOS_pbs
}