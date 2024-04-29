using namespace System.Net

function GET_DeviceCredantials {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    [CmdletBinding()]
    param (

    )
    $UserCredantials=@()
    <#Number of switches that Var will later use as IDs.#>
    Write-Host "Enter the Number (min.1 - max.9) of Device: " -ForegroundColor Yellow -NoNewline
    do {
        $SWnumber = Read-Host
        $vaNoD = $SWnumber -match '^[1-9]$'
        if (!($vaNoD)) {
            Write-Host "$SWnumber is not an valid Number." -ForegroundColor Red
            Write-Host -fore Yellow "Please Enter a valid Number: " -NoNewline
        }
    } until ($vaNoD)

    <#For IPAddr Check#>
    $IPPattern = '^(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$'
    if($SWnumber -ge 1){
        
        for ($Device =1; $Device -le $SWnumber;$Device++){
            Write-Host "Please enter Credantials for Device number: $Device "
            $CredantialsCollect=[ordered]@{}
            Write-Host "Please Enter IP: " -ForegroundColor Yellow -NoNewline
                <#Input Loop Until Validation meets pattern#>
                do {
                    <# Set IP address var #>
                    $IPADR = Read-Host
                    <# Check that the input matches the specification. #>
                    Start-Sleep -Seconds 1
                    $FOS_OnorOff=Test-Connection $IPADR -Count 1
                    Write-Debug -Message "Test-Connection to $IPADR was $($FOS_OnorOff.Status) ` "
                    $ok = $IPADR -match $IPPattern
                    if ($ok -eq $false) {
                    <# Error Message and Prompt to enter an IP #>
                    Write-Warning ("'{0}' is not an IP address." -f $IPADR)
                    write-host -fore Yellow "Please Enter IP: " -NoNewline
                    }
                    <#Condition#>
                } until ( $ok )

            <#Test the Conection to the device works but need more inprovement #>
            #$FOS_OnorOff=Test-Connection $IPADR -Count 1
            if($FOS_OnorOff.Status -ne "Success"){Write-Host "Your entered IP: $IPADR is not reachable, please check the connection and try again." -ForegroundColor Red;} #optional a Exit if no resp.
            $CredantialsCollect.Add('ID',$Device)
            $CredantialsCollect.Add('IPAddress',$IPADR)
           

            [string]$Protocol=Read-Host "
            1 - ssh
            2 - plink
            Please choose"
            switch ($Protocol) {
                1 { $Protocol="ssh" }
                2 { $Protocol="plink" }
            }
            $CredantialsCollect.Add('Protocol',$Protocol)
            [string]$UserName = Read-Host "enter the UserName of the device"
            $CredantialsCollect.Add('UserName',$UserName) 

            if($Protocol -eq "plink"){
                $UserPassword = Read-Host "enter the Password of the device"
                $UserPassword = ConvertTo-SecureString -String $UserPassword -AsPlainText
                $CredantialsCollect.Add('Password',$UserPassword)
            }
            
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