Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

function GUI_StartUp {
    [CmdletBinding()]
    param ( 
    )
    
    begin {
        Write-Debug -Message "Begin GUI_StartUp |$(Get-Date)"
        $PSRootPath = Split-Path -Path $PSScriptRoot -Parent
        $MainxamlFile ="$PSRootPath\GUI\MainWindow.xaml"
        Write-Debug -Message "MainxamlFile: $($MainxamlFile) |$(Get-Date)"
        $inputXAML=Get-Content -Path $MainxamlFile -raw
        Write-Debug -Message "inputXAML: $($inputXAML) |$(Get-Date)"
        $inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
        [xml]$MainXAML=$inputXAML
        $Mainreader = New-Object System.Xml.XmlNodeReader $MainXAML
        Write-Debug -Message "Mainreader: $($Mainreader) |$(Get-Date)"
        $Mainform=[Windows.Markup.XamlReader]::Load($Mainreader)
        $MainXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $Mainform.FindName($_.Name)}
    }
    
    process {
        Write-Debug -Message "process GUI_StartUp |$(Get-Date)"
        $TD_btn_SAN_Dashboard.add_click({
            Open_Brocade_Dashboard
        })
        
        $TD_btn_IBM_HostVolumeMap.add_click({
            GET_IBM_Host_Volume_Map
        })
        $TD_btn_IBM_DriveInfo.add_click({
            GET_IBM_DriveInfo
        })
        $TD_btn_IBM_FCPortStats.add_click({
            GET_IBM_FCPortStats
        })
         
        $TD_btn_CloseAll.add_click({
            $Mainform.Close()
        })

        Write-Debug -Message Get-Variable TD_* `n$(Get-Date)
        Get-Variable TD_*
    }
    
    end {
        Write-Debug -Message "end GUI_StartUp |$(Get-Date)"
        $Mainform.showDialog()
    }
}