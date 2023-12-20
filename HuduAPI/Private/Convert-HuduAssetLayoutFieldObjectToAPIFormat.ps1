function Convert-HuduAssetLayoutFieldObjectToAPIFormat {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        [AssetField[]]$Fields
    )
    begin {
        $fieldLabels = @()
    }
    process {
        Write-Debug "Processing [AssetField] to API format: $($Fields | ConvertTo-Json -Depth 10 -EnumsAsStrings)"
        $Fields | Foreach-Object {
            $nf = $_.id -eq 0 ? ($_ | Select-Object -ExcludeProperty 'id') : ($_ | Select-Object -Property *)
            $nf.field_type = switch ($nf.field_type) {
                'AssetLink' { 'AssetTag' }
                'ConfidentialText' { 'Password' }
                'CopyableText' { 'Email' }
                'Site' { 'Website' }
                Default { $nf.field_type }
            }
            if ($nf.options) { $nf.options = $nf.options -join "`n" }
            if ($nf.Label -iin $fieldLabels) {
                Write-Error "Duplicate field label found in layout. Field labels must be unique. Label: $($nf.Label)" -ErrorAction Stop
            }
            else { $fieldLabels += $nf.Label }
            $nf
        }
    }
}