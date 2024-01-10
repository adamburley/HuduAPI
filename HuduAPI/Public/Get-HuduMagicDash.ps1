    <#
    .SYNOPSIS
    Get company Magic Dash items

    .DESCRIPTION
    Get company Magic Dash dashboard items. Accepts company objects from the pipeline.

    .INPUTS
    [object]
    A company object as returned by Get-HuduCompany

    .OUTPUTS
    [object]
    [object[]]
    A single magic dash custom object or an array of magic dash custom objects

    .PARAMETER Company
    Return Magic Dash items for a specific company. If not specified, returns Magic Dash items for all companies.
    Accepts a Company object or Company ID.

    .PARAMETER Title
    Return Magic Dash items with a specific title. If the company is not specified, more than one Magic Dash item may be returned.

    .EXAMPLE
    Get-HuduMagicDash
    
    .EXAMPLE
    Get-HuduMagicDash -Company 1234

    .EXAMPLE
    Get-HuduMagicDash -Title 'Open Tickets'

    .LINK
    Set-HuduMagicDash

    .LINK
    Remove-HuduMagicDash
    #>
function Get-HuduMagicDash {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [Alias('company_id')]
        [object]$Company,

        [string]$Title
    )

    $_companyId = $Company | Find-ObjectIdByReference -Type Company

    $Params = @{
        company_id = $_companyId
        title      = $Title
    }
    $HuduRequest = @{
        Method   = 'GET'
        Resource = '/api/v1/magic_dash'
        Params   = $Params
    }
    Invoke-HuduRequestPaginated -HuduRequest $HuduRequest
}
