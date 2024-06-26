using namespace System.Net

function GET_ZoneDetails  {
    <#
    .SYNOPSIS
        Displays zone information.
    .DESCRIPTION
        Use this command to display zone configuration information. 
        This command includes sorting and search options to customize the output. 
        If a pattern is specified, the command displays only matching zone configuration names in the defined configuration. 
        When used without operands, the command displays all zone configuration information for the Defined and the Effective configuration.        
    .EXAMPLE
        not required
    .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.2.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]$FOS_MainInformation
    )
    begin{
        Write-Debug -Message "Begin GET_ZoneDetails |$(Get-Date)"

        $FOS_ZoneCollection = @()

        Write-Debug -Message "`nZoneliste`n $FOS_ZoneList,`nZoneEntrys`n $FOS_ZoneEntrys,`nZoneCount`n $FOS_ZoneCollection "
        
    }
    process{
        Write-Debug -Message "Start of Process from GET_ZoneDetails |$(Get-Date)"
        # Creat a list of Aliase with WWPN based on the decision by AliasName, with a "wildcard" there is only a list similar Aliasen or without a Aliasname there will be all Aliases of the cfg in the List.

        #$FOS_BasicZoneList = Get-Content -Path ".\Schl_Fab2.txt"
        #$FOS_BasicZoneList = ssh $UserName@$($SwitchIP) "zoneshow"
        $FOS_ZoneCount = $FOS_MainInformation.count

        0..$FOS_ZoneCount |ForEach-Object {
            # Pull only the effective ZoneCFG back into ZoneList
            if($FOS_MainInformation[$_] -match '^Effective'){
                $FOS_ZoneList = $FOS_MainInformation |Select-Object -Skip $_
                #break
            }
        }

        Write-Debug -Message "FOS_Operand Default`n, Search: zoneshow`n, Zoneliste`n $FOS_ZoneCount, `nZoneEntrys`n $FOS_MainInformation, `nZoneCount`n $FOS_ZoneList "

        # is not necessary, but even a system needs a break from time to time
        Start-Sleep -Seconds 2;

        # Creat a List of Aliases with WWPN based on switch-case decision
        if(($FOS_ZoneList.count) -ge 4){
            #Create PowerShell Objects out of the Aliases
            foreach ($FOS_Zone in $FOS_ZoneList) {
                $FOS_TempCollection = "" | Select-Object Zone,WWPN,Alias
                # Get the ZoneName
                if(Select-String -InputObject $FOS_Zone -Pattern '^ zone:\s+(.*)'){
                    $FOS_AliName = Select-String -InputObject $FOS_Zone -Pattern '^ zone:\s+(.*)' |ForEach-Object {$_.Matches.Groups[1].Value}
                    $FOS_TempCollection.Zone = $FOS_AliName.Trim()
                    Write-Debug -Message "$FOS_TempCollection"
                }elseif(Select-String -InputObject $FOS_Zone -Pattern '(:[\da-f]{2}:[\da-f]{2}:[\da-f]{2})$') {
                    $FOS_AliWWN = $FOS_Zone
                    $FOS_TempCollection.WWPN = $FOS_AliWWN.Trim()
                    <# Boolean to control the do until loop #>
                    $FOS_DoUntilLoop = $true
                    foreach($FOS_BasicZoneListTemp in $FOS_MainInformation){
                        <# Start of the do until loop #>
                        do {
                            if($FOS_BasicZoneListTemp -match '^ alias:\s(.*)'){
                                Write-Debug -Message "$FOS_BasicZoneListTemp "
                                $FOS_TeampAliasName = $FOS_BasicZoneListTemp
                                $FOS_TempAliasName = $FOS_TeampAliasName -replace '^ alias:\s',''.Trim()
                                break
                            }

                            if($FOS_BasicZoneListTemp -match ($FOS_AliWWN.Trim())){
                                Write-Debug -Message " $FOS_BasicZoneListTemp "
                                $FOS_DoUntilLoop = $false
                                $FOS_TempCollection.Alias = $FOS_TempAliasName
                                break
                            }
                            break
                            
                        } until (

                            $FOS_DoUntilLoop -eq $true
                        )
                        <# Boolean to control the do until loop with break out option #>
                        If($FOS_DoUntilLoop -eq $false){break}
                    }

                    Write-Debug -Message "$FOS_AliName`n, $FOS_Zone"
                }else{
                    <# Action when all if and elseif conditions are false #>
                    Write-Host "`n"
                }
                $FOS_ZoneCollection += $FOS_TempCollection
            }

            Write-Debug "Here is the list of zones with WWPNs and their corresponding aliases:" -ForegroundColor Green
            $FOS_ZoneCollection

            #Write-Debug -Message "$FOS_ZoneCollection `nEnd of Process block |$(Get-Date)"

        }else {
             <# Action when all if and elseif conditions are false #>
            Write-Host "Something wrong, notthing was not found. " -ForegroundColor red
            Write-Debug -Message "Some Infos: notthing was found, ZoneEntry count: $($FOS_ZoneList.count)`n, $FOS_ZoneList"
        }

    }
    end{
        # clear the most of the used vars
        Write-Debug -Message "End block |$(Get-Date)"
    }
}
