function Get-HuduCardJumplink {
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    param(
        [parameter(ValueFromPipeline, ParameterSetName = 'Template', Mandatory)]
        [object]$Asset,

        [ArgumentCompletions('ninja', 'cw_manage', 'auvik', 'syncro', 'liongard', 'datto', 'office_365', 'atera', 'autotask', 'dattormm', 'halo', 'bms', 'nsight', 'pulseway_rmm', 'repairshopr', 'domotz', 'watchman')]
        [string]$Integrator,

        [parameter(ParameterSetName = 'Template')]
        [switch]$GetTemplate
    )
    begin {
        if ($GetTemplate) {
            $templates = @{}
        }
    }
    process {
        foreach ($aO in $Asset) {
            if ($aO.GetType().Name -iin 'Int', 'Int32', 'Int64') {
                # Asset is an ID
                $aO = Get-HuduAsset -Id $aO
            }
            elseif ($aO.GetType().Name -ieq 'String') {
                $aO = Get-HuduAsset -Name $aO
            }
            if (-not $aO.cards) { Write-Information "No card information found for Asset $($aO.name) [$($aO.Id)]"; continue }

            # Filter cards by integrator if requested
            $_cards = $Integrator ? ($aO.cards | Where-Object { $_.integrator_name -eq $Integrator }) : $aO.cards
            foreach ($c in $_cards) {
                $idSegment = $c.sync_id ? "integration_id=$($c.sync_id)" : "integration_identifier=$($c.sync_identifier)"
                $type = $c.sync_type
                $slug = $c.integrator_name
                $url = "{0}/api/v1/cards/jump?integration_slug={1}&integration_type={2}&{3}" -f (Get-HuduBaseURL), $slug, $type, $idSegment

                if ($GetTemplate) {
                    $compoundIdentifier = "$slug|$type"
                    if ($compoundIdentifier -notin $templates.Keys) {
                        $newTemplate = [PSCustomObject][ordered]@{
                            Slug         = $slug
                            Type         = $type
                            IdQueryParam = $c.sync_id ? 'integration_id' : 'integration_identifier'
                            AssetLayouts = @(($aO.asset_type | Select-Object -Unique))
                            Example      = $url
                        }
                        $templates.Add($compoundIdentifier, $newTemplate)
                    }
                    else {
                        $aO.asset_type | Where-Object { $_ -notin $templates[$compoundIdentifier].AssetLayouts } | ForEach-Object { 
                            $templates[$compoundIdentifier].AssetLayouts += $_
                        }
                    }
                }
                else {
                    $url
                }
            }
        }
    }
    end {
        if ($GetTemplate) {
            $result = $templates.Values | Sort-Object Slug, TypesToProcess
            $result | ForEach-Object {
                $_.AssetLayouts = $_.AssetLayouts | Sort-Object
            }
            return $result
        }
    }
}