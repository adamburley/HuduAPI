# TODO - issue with returning object where a presented ID integer is returned, not the object
function Find-ObjectIdByReference {
    [CmdletBinding(PositionalBinding)]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [AllowNull()][AllowEmptyString()]
        [object]$Reference,

        [Parameter(Position = 0, Mandatory)]
        [ValidateSet('Article', 'Asset', 'Company', 'AssetLayout', 'Website')]
        [string]$Type,

        [Parameter()]
        [switch]$ReturnObject
    )
    process {
        if ($null -eq $Reference) { return $null }
        if ($Reference.GetType().Name -eq 'PSCustomObject') { $result = $ReturnObject ? $Reference : $Reference.id }
        elseif ($Reference.GetType().Name -iin @('Int32', 'Int64') -and -not $ReturnObject) { $result = $Reference }
        else {
            $splat = if ($Reference.GetType().Name -iin @('Int32', 'Int64')) { @{ Id = $Reference } } else {
                @{ Name = $Reference }
            }
            $result = switch ($Type) {
                'Article' { Get-HuduArticle @splat }
                'Company' { Get-HuduCompany @splat }
                'AssetLayout' { Get-HuduAssetLayout @splat }
                'Asset' { Get-HuduAsset @splat }
                'Website' { Get-HuduWebsite @splat }
            }
            if ($result.Count -eq 1) { 
                $result = $ReturnObject ? $result : $result.id
            }
            else { Write-Error "Unable to identify $Type '$Reference' or more than one result returned."; $null }
        }
        Write-Debug "Found $Type [$id] from [$($Reference.GetType().Name)]$($Reference | ConvertTo-Json -Depth 5 -Compress)"
        return $result
    }
}