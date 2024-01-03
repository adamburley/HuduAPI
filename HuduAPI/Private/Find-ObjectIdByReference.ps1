function Find-ObjectIdByReference {
    [CmdletBinding(PositionalBinding)]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [AllowNull()][AllowEmptyString()]
        [object]$Reference,

        [Parameter(Position = 0, Mandatory)]
        [ValidateSet('Asset','Company', 'AssetLayout')]
        [string]$Type
    )
    process {
        if ($null -eq $Reference) { return $null }
        $id = switch ($Reference.GetType().Name) {
            'PSCustomObject' { $Reference.id }
            {$_ -iin @('Int32','Int64')} { $Reference }
            'string' {
                $matchedObject = switch ($Type) {
                    'Company' { Get-HuduCompany -Name $Reference }
                    'AssetLayout' { Get-HuduAssetLayout -Name $Reference }
                    'Asset' { Get-HuduAsset -Name $Reference }
                }
                if ($matchedObject.Count -eq 1) { $matchedObject.id }
                else { Write-Error "Unable to identify $Type '$Reference' or more than one result returned."; $null }
            }
            Default { Write-Error "Unable to determine value of $Type parameter."; $null }
        }
        Write-Debug "Found $Type [$id] from [$($Reference.GetType().Name)]$($Reference | ConvertTo-Json -Depth 5 -Compress)"
        return $id
    }
}