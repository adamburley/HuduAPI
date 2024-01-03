function Get-HuduAsset {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Id')]
        [int]$Id,
    
        [Parameter(ParameterSetName = 'Default')]
        [string]$Name, # Exact name

        [Parameter(ParameterSetName = 'Slug')]
        [string]$Slug, # Exact slug

        [Parameter(ParameterSetName = 'Default')]
        [Alias('primary_serial')]
        [string]$PrimarySerial, # Exact primary serial, not necessarily added by integrations

        [Parameter(ParameterSetName = 'Default')]
        [Alias('CompanyId', 'company_id')]
        [Object]$Company,
    
        [Parameter(ParameterSetName = 'Default')]
        [Alias('AssetLayout', 'AssetLayoutId', 'asset_layout_id')]
        [Object]$Layout,

        [Parameter(ParameterSetName = 'Slug')]
        [Parameter(ParameterSetName = 'Id')]
        [Parameter(ParameterSetName = 'Default')]
        [switch]$Archived,

        [Parameter(ParameterSetName = 'Default')]
        [Alias('search')]
        [string]$SearchQuery, # May not return expected results for short strings or strings with special characters.

        [Parameter(ParameterSetName = 'Default')]
        [DateTime]$UpdatedAfter, # May return HTTP 500 if both are not specified
        [Parameter(ParameterSetName = 'Default')]
        [DateTime]$UpdatedBefore,

        [switch]$FieldsAsHashtable,

        [parameter(ValueFromPipeline, ParameterSetName = 'Default')]
        [PSCustomObject]$InputObject
    )

    process {
        # Disambiguate any input to the pipeline or multi-type parameters
        if ($InputObject) {
            if ($InputObject.url) {
                # Company object
                if ($Company) { Write-Error "Duplicate input - Pipeline and parameter both contain a Company object" }
                Write-Debug "InputObject is a Company object: $($InputObject | ConvertTo-Json -Depth 5 -Compress)"
                $companyId = $InputObject.id
            }
            elseif ($InputObject.icon) {
                # Layout object
                if ($Layout) { Write-Error "Duplicate input - Pipeline and parameter both contain an AssetLayout object" }
                Write-Debug "InputObject is an AssetLayout object: $($InputObject | ConvertTo-Json -Depth 5 -Compress)"
                $layoutId = $InputObject.id
            }
            else {
                Write-Error "Pipeline input must be either a Company or AssetLayout object"
            }
        }
        if (-not $companyId) { $companyId = $Company | Find-ObjectIdByReference -Type Company }
        if (-not $layoutId) { $layoutId = $Layout | Find-ObjectIdByReference -Type AssetLayout }

        # As of Hudu V2.27 calls including only part of the date range may return HTTP 500. This differs from the documented behavior. 
        # Workaround is to always specify both if one is set.
        if ($UpdatedAfter -or $UpdatedBefore) {
            $afterString = $UpdatedAfter ? $UpdatedAfter.ToString('o') : (Get-Date).AddYears(-100).ToString('o')
            $beforeString = $UpdatedBefore ? $UpdatedBefore.ToString('o') : (Get-Date).ToString('o')
            $updatedAt = "$afterString,$beforeString"
        }
        $Params = @{}
        if ($Id) { $Params.id = $Id }
        if ($Name) { $Params.name = $Name }
        if ($companyId) { $Params.company_id = $companyId }
        if ($layoutId) { $Params.asset_layout_id = $layoutId }
        if ($PrimarySerial) { $Params.primary_serial = $PrimarySerial }
        if ($Slug) { $Params.slug = $Slug }
        if ($Archived) { $Params.archived = $true }
        if ($SearchQuery) { $Params.search = $SearchQuery }
        if ($updatedAt) { $Params.updated_at = $updatedAt }
    
        Write-Verbose "Request parameters: $($Params | ConvertTo-Json -Depth 3 -Compress)"

        $HuduRequest = @{
            Resource = '/api/v1/assets'
            Method   = 'GET'
            Params   = $Params
        }
        if ($result = Invoke-HuduRequestPaginated -HuduRequest $HuduRequest -Property assets) {
            if ($FieldsAsHashtable) {
                $ht = @{}
                $result.fields | ForEach-Object {
                    $ht.add($_.label.Replace(' ', '_').ToLower(), $_.value)
                }
                $result.fields = $ht
                return $result
            }
            else { return $result }
        }
    }
}