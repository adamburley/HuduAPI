## TODO Learning / testing cmdlet - may not be required.

<#
.SYNOPSIS
Converts a JSON object to an asset field.

.DESCRIPTION
This function takes a JSON object and converts it into an asset field. It is used in the HuduAPI module.

.PARAMETER Json
The JSON object to be converted.

.OUTPUTS
The converted asset field.

.EXAMPLE
$json = '{"name": "John", "age": 30}'
Convert-HuduJsonToAssetField -Json $json

This example converts a JSON object into an asset field.

#>
function Convert-HuduJsonToAssetField {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$JSON
    )

    process {
        $obj = $JSON | ConvertFrom-Json
        switch ($obj.field_type) {
            'AssetTag' { $obj.field_type = 'AssetLink'; return [AssetLinkField]$obj } 
            'Password' { $obj.field_type = 'ConfidentialText' }
            'Email' { $obj.field_type = 'CopyableText' }
            'Website' { $obj.field_type = 'Site' }
            'Date' { return [DateField]$obj }
            'Number' { return [NumberField]$obj }
            'Dropdown' { return [DropdownField]$obj }
            Default { return [AssetField]$obj }
        }

    }
}