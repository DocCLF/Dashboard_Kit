using namespace System.Net
function Device_Credantials {
    $test=@()
    [Int16]$SWnumber = Read-Host "How many Switches"
    <#For IPAddr Check#>
    $IPPattern = '^(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$'
    if($SWnumber -ge 1){
        Write-Host $SWnumber
        for ($Device =1; $Device -le $SWnumber;$Device++){
            $Prop=[ordered]@{}
            Write-Host "Please Enter IP: " -ForegroundColor Yellow -NoNewline
                <#Input Loop Until Validation meets pattern#>
                do {
                    <# Set IP address var #>
                    $IPADR = Read-Host
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
            $UserPassword = Read-Host "enter the Password of the device" -AsSecureString

            $Prop.Add('ID',$Device)
            $Prop.Add('Protocol',$Protocol)
            $Prop.Add('IPAddress',$IPADR)
            $Prop.Add('UserName',$UserName)

            $obj=New-Object -TypeName psobject -Property $Prop

            $test+=$obj
        }
    }
    return $test
}