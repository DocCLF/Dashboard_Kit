Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$MainxamlFile =".GUI\MainWindow.xaml"
$inputXAML=Get-Content -Path $MainxamlFile -raw
$inputXAML=$inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace "^<Win.*","<Window"
[xml]$MainXAML=$inputXAML
$Mainreader = New-Object System.Xml.XmlNodeReader $MainXAML
$Mainform=[Windows.Markup.XamlReader]::Load($Mainreader)
$MainXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name "TD_$($_.Name)" -Value $Mainform.FindName($_.Name)}

$TD_btn_SAN_Dashboard.add_click({
    Open_Brocade_Dashboard
})

$TD_btn_IBM_HostVolumeMap.add_click({
    IBM_Host_Volume_Map
})
$TD_btn_IBM_DriveInfo.add_click({
    IBM_DriveInfo
})
$TD_btn_IBM_FCPortStats.add_click({
    IBM_FCPortStats
})
 
$TD_btn_CloseAll.add_click({
    $Mainform.Close()
})

Get-Variable TD_*


$Mainform.showDialog()