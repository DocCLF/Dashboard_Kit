# Universal psm file
# Requires -Version 5.0

# Get functions files
$Functions = @(Get-ChildItem -Path $PSScriptRoot\Scripts\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach($import in @($Functions)) {
    try {
       . $import.fullname
        Write-Host $import.fullname
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
<# Maybe for later use
if ($FoundErrors.Count -gt 0) {
    $ModuleName = (Get-ChildItem $PSScriptRoot\*.psd1).BaseName
    Write-Warning "Importing module $ModuleName failed. Fix errors before continuing."
    break
}
#>

# Export everything in the public folder
Export-ModuleMember -Function * -Cmdlet * -Alias *