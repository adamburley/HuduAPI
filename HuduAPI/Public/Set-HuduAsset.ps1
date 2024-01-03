<#
.SYNOPSIS
Update an asset in Hudu

.DESCRIPTION
Create a new asset in Hudu. Supports piping from an object created by Get-HuduAsset.
Supports updating custom field data by custom object array (as returned by Get-HuduAsset) or by hashtable.
See Examples for more information.

.PARAMETER Name
Displayed name of the asset. Note, this may be constrained by custom layout settings, which are not currently available via API.

.PARAMETER Company
Company associated with the asset. This parameter accepts an object, ID, or name.
Must be the same company the asset is currently associated with. If not provided, will be retrieved during processing.

.PARAMETER Layout
Layout of the asset. This parameter accepts an object, ID, or name.

.PARAMETER Fields
Specifies additional custom fields for the asset. This parameter accepts a hashtable or an array of objects.
If utilizing a hashtable, the key should be the field label, in lower case with spaces replaced by underscores.
If utilizing an array of objects, the objects should have the following properties:
    label: The field label, either in the format provided by Get-HuduAsset or displayed in the UI, or in lower_snake_case.
    value: The field value.

.PARAMETER Id
Specifies the ID of the asset to update.

.PARAMETER PrimarySerial
Specifies the primary serial number of the asset.

.PARAMETER PrimaryMail
Specifies the primary email associated with the asset.

.PARAMETER PrimaryModel
Specifies the primary model of the asset.

.PARAMETER PrimaryManufacturer
Specifies the primary manufacturer of the asset.

.INPUTS
[object]
A custom object created by Get-HuduAsset

.OUTPUTS
The updated asset object as returned by the API.

.EXAMPLE
# Basic usage
Set-HuduAsset -Name "Jenny's Laptop" -Id 8675309 -PrimaryModel "Updated Model" -Fields @{ 'primary_user' = 'Jenny'; 'in_warranty' = $true }

.EXAMPLE
# Update custom fields by hashtable
$asset = Get-HuduAsset -Id 8675309 -FieldsAsHashtable
$asset.Name = "Jenny's Laptop"
$asset.Fields.primary_user = 'Jenny'
$asset.Fields.in_warranty = $true
$asset | Set-HuduAsset

.EXAMPLE
# Update custom fields by object array
$asset = Get-HuduAsset -Id 8675309
$asset.Fields | select label, value

label           value
-----           -----
Notes           my notes
Primary User    Stacy's Mom
In Warranty     False

$asset.Fields[1].value = "Jenny's Laptop"
$asset.Fields[2].value = $true
$asset | Set-HuduAsset

.LINK
Get-HuduAsset
#>
function Set-HuduAsset {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('company_id')]
        [ValidateNotNullOrEmpty()]
        [object]$Company,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('asset_layout_id')]
        [ValidateNotNullOrEmpty()]
        [object]$Layout,

        [Parameter(ValueFromPipelineByPropertyName)]
        $Fields,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('asset_id', 'assetid')]
        [Int]$Id,

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
        $Asset = @{}
        $companyId = $Company | Find-ObjectIdByReference -Type Company
        if (-not $companyId) { $companyId = Get-HuduAsset -Id $Id | Select-Object -ExpandProperty company_id }
        $layoutId = $Layout | Find-ObjectIdByReference -Type AssetLayout

        if ($Name) { $Asset.name = $Name }
        if ($companyId) { $Asset.company_id = $companyId }
        if ($layoutId) { $Asset.asset_layout_id = $layoutId }
        if ($PrimarySerial) { $Asset.primary_serial = $PrimarySerial }
        if ($PrimaryMail) { $Asset.primary_mail = $PrimaryMail }
        if ($PrimaryModel) { $Asset.primary_model = $PrimaryModel }
        if ($PrimaryManufacturer) { $Asset.primary_manufacturer = $PrimaryManufacturer }

        if ($Fields) {
            switch ($Fields.GetType().Name) {
                'hashtable' { $Asset.custom_fields = @($Fields) }
                'object[]' {
                    $Asset.custom_fields = @(@{})
                    $Fields | ForEach-Object {
                        $Asset.custom_fields[0].add($_.label.ToLower().Replace(' ', '_'), $_.value)
                    }
                }
            }
        }
        $JSON = @{ asset = $Asset } | ConvertTo-Json -Depth 10

        Write-Verbose "JSON: $JSON"

        if ($PSCmdlet.ShouldProcess("Update Asset [$Id] `"$Name`"", "Asset", "Update asset via API")) {
            Invoke-HuduRequest -Method put -Resource "/api/v1/companies/$CompanyId/assets/$Id" -Body $JSON | Select-Object -ExpandProperty asset
        }
    }
}
