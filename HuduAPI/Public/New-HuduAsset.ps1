<#
.SYNOPSIS
Create a new asset in Hudu.

.DESCRIPTION
Create a new asset in Hudu. Supports piping from an asset template object returned by Get-HuduAssetTemplate, or from a custom object with the same properties.

.PARAMETER Name
The name of the asset.

.PARAMETER Company
The company associated with the asset. Supports object, ID, or name.

.PARAMETER Layout
The layout of the asset. Supports object, ID, or name.

.PARAMETER Fields
Custom fields for the asset. Supports the custom object created by Get-HuduAssetTemplate, or a [hashtable] of key-value pairs.
If utilizing a hashtable, the key should be the field label, in lower case with spaces replaced by underscores.

.PARAMETER PrimarySerial
The primary serial number of the asset.

.PARAMETER PrimaryMail
The primary mail of the asset.

.PARAMETER PrimaryModel
The primary model of the asset.

.PARAMETER PrimaryManufacturer
The primary manufacturer of the asset.

.EXAMPLE
New-HuduAsset -Name "My new asset" -Company 2 -Layout 12

.EXAMPLE
# Common application. Create a new asset in the ISP layout under company "Contoso, Inc." with custom fields populated.
$template = Get-HuduAssetTemplate -Layout 'ISP'
$company = Get-HuduCompany -Name 'Contoso, Inc.'
$template.Name = "Supergreat ISP"
$template.Fields.type = "Fiber"
$template.Fields.contracted_speed = "200/50"
$template.Fields.notes = "Jeremy Bearamy is our billing contact."
$template | Add-HuduAsset -Company $company

.LINK
Get-HuduAssetTemplate
#>
function New-HuduAsset {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('company_id')]
        [object]$Company,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('asset_layout_id', 'AssetLayout', 'AssetLayoutId')]
        [object]$Layout,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('custom_fields')]
        [object]$Fields,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('primary_serial')]
        [string]$PrimarySerial,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('primary_mail')]
        [string]$PrimaryMail,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('primary_model')]
        [string]$PrimaryModel,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('primary_manufacturer')]
        [string]$PrimaryManufacturer
    )
    process {
        $layoutId = $Layout | Find-ObjectIdByReference -Type AssetLayout
        $companyId = $Company | Find-ObjectIdByReference -Type Company

        $Asset = [ordered]@{
            name            = $Name
            company_id      = $companyId
            asset_layout_id = $layoutId
        }
        if ($Fields) {
            if ($Fields -is [hashtable[]]) { $Asset.custom_fields = $Fields }
            else {
                $Asset.custom_fields = @(@{})
            ($Fields | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) | ForEach-Object {
                    if ($null -ne $Fields.$_) { $Asset.custom_fields[0].add($_, $Fields.$_) }
                }
            }
        }

        $JSON = @{ asset = $Asset } | ConvertTo-Json -Depth 10
        Write-Verbose "JSON: $JSON"

        if ($PSCmdlet.ShouldProcess("Create new Asset `"$Name`" with layout [$layoutId] under company [$companyId].", "Asset", "Create new asset via API")) {
            Invoke-HuduRequest -Method post -Resource "/api/v1/companies/$CompanyId/assets" -Body $JSON | Select-Object -ExpandProperty asset
        }
    }
}
