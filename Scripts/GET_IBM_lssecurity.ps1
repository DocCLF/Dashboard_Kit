using namespace System.Net

function GET_IBM_lssecurity {
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
    
    begin {
        Write-Debug -Message "Begin GET_ZoneDetails |$(Get-Date)"

        $TD_UnfiltertData = Get-Content -Path ""
        $TD_FiltertDatas = $TD_UnfiltertData |Select-Object -Skip 1 -SkipLast 1
    }
    process {
        $ServiceDataTable=New-Object System.Data.DataTable
        [void]$ServiceDataTable.Columns.AddRange($Columns)
        foreach($TD_FiltertData in $TD_FiltertDatas){
            $a,$b = $TD_FiltertData.Split(":")[0,-1]
            [void]$ServiceDataTable.Rows.Add(@($a,$b))
        }
        $TD_dg_UserContrOne.ItemsSource=$ServiceDataTable.DefaultView
        $TD_dg_UserContrOne.IsReadOnly=$true
        $TD_dg_UserContrOne.GridLinesVisibility="None"
    }
    
    end {
        return $TD_dg_UserContrOne
    }
}