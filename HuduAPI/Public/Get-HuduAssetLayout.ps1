function Get-HuduAssetLayout {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name, # TODO - Doc - may return more than one layout as duplicate names are allowed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [alias('layout_id', 'LayoutId')]
        [int]$Id, # TODO this make more sense as LayoutId if it allows pipelining from an Asset object.
        [Parameter()]
        [string]$Slug, # TODO - Doc - this appears to be broken and returns HTTP 500 in all cases
        [Parameter()]
        [DateTime]$UpdatedAfter,
        [Parameter()]
        [DateTime]$UpdatedBefore
    )
    process {
        if ($Id) {
            if ($layout = Invoke-HuduRequest -Resource "/api/v1/asset_layouts/$Id" -Method GET | Select-Object -ExpandProperty asset_layout) {
                $layout.fields = $layout.fields | New-HuduAssetLayoutField | Sort-Object -Property position
                return $layout
            } else {
                Write-Warning "No layout found with ID [$Id]."
                return $null
            }
        }
        if ($Slug) { Write-Warning "Slug parameter does not appear supported and no results are returned for any query as of Hudu V2.27. Query will continue." }
        $HuduRequest = @{
            Resource = '/api/v1/asset_layouts'
            Method   = 'GET'
            Params = @{
                name = $Name
                slug = $Slug
            }
        }
        if ($UpdatedAfter -or $UpdatedBefore) {
            $afterString = $UpdatedAfter ? $UpdatedAfter.ToString('o') : $null
            $beforeString = $UpdatedBefore ? $UpdatedBefore.ToString('o') : $null
            $HuduRequest.Param.updated_at = "$afterString,$beforeString"
        }
        Write-Verbose "Request parameters: $($HuduRequest | ConvertTo-Json -Depth 3 -Compress)"
        $AssetLayouts = Invoke-HuduRequestPaginated -HuduRequest $HuduRequest -Property 'asset_layouts' -PageSize 25
        $AssetLayouts | ForEach-Object {
            $_.fields = $_.fields | New-HuduAssetLayoutField | Sort-Object -Property position
        }
        Write-Debug "Retrieved $($AssetLayouts.Count) layouts."
        return $AssetLayouts
    }
}