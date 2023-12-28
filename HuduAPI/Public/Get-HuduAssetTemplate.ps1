<#
.SYNOPSIS
Get a blank template for a Hudu asset with Layout-specific questions.

.DESCRIPTION
Returns a custom object with standard asset fields and a Fields property containing the layout-specific fields.
Additionally, a FieldInformation property is included with the layout-specific fields' label, type, required status, and options.
Use this with New-HuduAsset to create a new asset and populate custom fields.

.PARAMETER Layout
The layout to retrieve. Accepts a Layout object, name, or ID.

.INPUTS
Layout object, name, or ID.

.OUTPUTS
[PSCustomObject]

.EXAMPLE
$template = Get-HuduAssetTemplate -Layout 12
$template.name = "My new asset"
$template.Fields.notes = "This is a test asset."
$template | Add-HuduAsset -Company $company

.LINK
New-HuduAsset
#>
function Get-HuduAssetTemplate {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline, Mandatory)]
        [object]$Layout
    )
    process {
        if ($layoutId = $Layout | Find-ObjectIdByReference -Type AssetLayout) {
                $_layout = Get-HuduAssetLayout -Id $layoutId
                $template = [PSCustomObject]@{
                        Name = $null
                        AssetLayoutId = $layoutId
                        PrimarySerial = $null
                        PrimaryMail = $null
                        PrimaryModel = $null
                        PrimaryManufacturer = $null
                        Fields = [PSCustomObject][ordered]@{}
                        FieldInformation = @()
                }
                $_layout.fields | ForEach-Object {
                        $template.Fields | Add-Member -MemberType NoteProperty -Name $_.label.replace(' ','_').ToLower() -Value $null
                        $template.FieldInformation += [PSCustomObject]@{
                                Label = $_.label.replace(' ','_').ToLower()
                                Type = $_.field_type
                                Required = $_.required
                                Options = $_.options
                        }
                }
                return $template
        }
        else {
                Write-Error "Unable to find Asset Layout for $($Layout | ConvertTo-Json -Depth 5 -Compress)" -ErrorAction Stop
        }
    }
}