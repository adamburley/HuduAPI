# TODO: Handle pipeline input of Company objects
# TODO: Handle pipeline input of Assetlayout objects

function Get-NewHuduAsset {
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
        [string]$SearchTerm, # May not return expected results for short strings or strings with special characters.

        [Parameter(ParameterSetName = 'Default')]
        [DateTime]$UpdatedAfter, # May return HTTP 500 if both are not specified
        [Parameter(ParameterSetName = 'Default')]
        [DateTime]$UpdatedBefore,

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
        if ($Company) {
            $companyId = switch ($Company.GetType()) {
                'PSCustomObject' { $Company.id }
                'int' { $Company }
                'string' {
                    if (($cObj = Get-HuduCompany -Name $Company) -and $cObj.Count -eq 1) { $cObj.id }
                    else {
                        Write-Warning "Unable to identify company '$Company' or more than one result returned. Omitting from call."
                        $null
                    }
                }
                Default { Write-Warning 'Unable to determine value of -Company parameter. Omitting from call.'; $null }
            }
        }
        if ($Layout) {
            $layoutId = switch ($Layout.GetType()) {
                'PSCustomObject' { $Layout.id }
                'int' { $Layout }
                'string' {
                    if (($lObj = Get-HuduAssetLayout -Name $Layout) -and $lObj.Count -eq 1) { $lObj.id }
                    else {
                        Write-Warning "Unable to identify asset layout '$Layout' or more than one result returned. Omitting from call."
                        $null
                    }
                }
                Default { Write-Warning 'Unable to determine value of -AssetLayout parameter. Omitting from call.'; $null }
            }
        }
        if ($UpdatedAfter -or $UpdatedBefore) {
            $afterString = $UpdatedAfter ? $UpdatedAfter.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") : $null
            $beforeString = $UpdatedBefore ? $UpdatedBefore.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") : $null
            $updatedAt = "$afterString,$beforeString"
        }
        if ($UpdatedAfter -ne $UpdatedBefore) {
            Write-Warning "As of Hudu V2.27 calls including only part of the date range may return HTTP 500. This differs from the documented behavior. Specify both -UpdatedAfter and -UpdatedBefore if an error occurs."
        }
        $Params = @{}
        if ($Id) { $Params.id = $Id }
        if ($Name) { $Params.name = $Name }
        if ($companyId) { $Params.company_id = $companyId }
        if ($layoutId) { $Params.asset_layout_id = $layoutId }
        if ($PrimarySerial) { $Params.primary_serial = $PrimarySerial }
        if ($Slug) { $Params.slug = $Slug }
        if ($Archived) { $Params.archived = $true }
        if ($SearchTerm) { $Params.search = $SearchTerm }
        if ($updatedAt) { $Params.updated_at = $updatedAt }
    
        Write-Verbose "Request parameters: $($Params | ConvertTo-Json -Depth 3 -Compress)"

        $HuduRequest = @{
            Resource = '/api/v1/assets'
            Method   = 'GET'
            Params   = $Params
        }
        Invoke-HuduRequestPaginated -HuduRequest $HuduRequest -Property assets
    }
}