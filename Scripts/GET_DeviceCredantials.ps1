using namespace System.Net

function GET_DeviceCredantials {
    $UserCredantials=@()
    <#Number of switches that Var will later use as IDs.#>
    [Int16]$SWnumber = Read-Host "How many Switches"

    <#For IPAddr Check#>
    $IPPattern = '^(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$'
    if($SWnumber -ge 1){
        Write-Host $SWnumber
        for ($Device =1; $Device -le $SWnumber;$Device++){
            $CredantialsCollect=[ordered]@{}
            Write-Host "Please Enter IP: " -ForegroundColor Yellow -NoNewline
                <#Input Loop Until Validation meets pattern#>
                do {
                    <# Set IP address var #>
                    $IPADR = Read-Host
                    <# Check that the input matches the specification. #>
                    $ok = $IPADR -match $IPPattern
                    if ($ok -eq $false) {
                    <# Error Message and Prompt to enter an IP #>
                    Write-Warning ("'{0}' is not an IP address." -f $IPADR)
                    write-host -fore Yellow "Please Enter IP: " -NoNewline
                    }
                    <#Condition#>
                } until ( $ok )

            <#Test the Conection to the device works but need more inprovement #>
            #$OnorOff=Test-Connection $IPADR -Count 1
            #if($OnorOff.Status -eq "TimedOut"){Write-Host "exit"; continue}

            [string]$Protocol=Read-Host "
            1 - ssh
            2 - plink
            Please choose"
            switch ($Protocol) {
                1 { $Protocol="ssh" }
                2 { $Protocol="plink" }
            }
            [string]$UserName = Read-Host "enter the UserName of the device"
            if($Protocol -eq "plink"){
                $UserPassword = Read-Host "enter the Password of the device" -AsSecureString
            }

            $CredantialsCollect.Add('ID',$Device)
            $CredantialsCollect.Add('Protocol',$Protocol)
            $CredantialsCollect.Add('IPAddress',$IPADR)
            $CredantialsCollect.Add('UserName',$UserName)

            <# Maybe for later use as a Export Obj #>
            $CredantialObj=New-Object -TypeName psobject -Property $CredantialsCollect
            #$ExportCredantials = $CredantialObj | Select-Object ID,UserName,IPAddress,Protocol | Export-Csv -Path ".\ExportCredantials.csv" -NoTypeInformation

            $UserCredantials+=$CredantialObj
            #$UserCredantials+=$CredantialsCollect
        }
    }else {
        Write-Host "We need the Credantials of min one Device!`nYou are now exiting the script, please restart it." -ForegroundColor Red
        exit
    }
    return $UserCredantials
}