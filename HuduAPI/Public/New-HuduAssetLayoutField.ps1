function New-HuduAssetLayoutField {
    [Alias('New-ALF')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter()]
        [string]$Label,
        [Parameter()]
        [Alias('field_type', 'FieldType')]
        [AssetFieldType]$Type,
        [Parameter()]
        [ValidateRange(1, 1000)]
        [int]$Position = 1,
        [Parameter()]
        [switch]$Required,
        [Parameter()]
        [string]$Hint,
        [Parameter()]
        [Alias('show_in_list')]
        [switch]$ShowInList,
        [Parameter(ParameterSetName = 'Number')]
        [int]$Min,
        [Parameter(ParameterSetName = 'Number')]
        [int]$Max,
        [Parameter(ParameterSetName = 'Dropdown')]
        [string[]]$Options,
        [Parameter(ParameterSetName = 'AssetLink')]
        [Alias('linkable_id')]
        [int]$AssetTypeId,
        [Parameter(ParameterSetName = 'Date')]
        [Alias('Expiration')]
        [switch]$AddToExpirations,
        [Parameter(ParametersetName = 'FromObject', ValueFromPipeline = $true)]
        [PSCustomObject[]]$Object
    )
    process {
        if ($Object) {
            foreach ($J in $Object) {
                switch ($J.field_type) {
                    'AssetTag' { $J.field_type = 'AssetLink'; return [AssetLinkField]($J | Select-Object -ExcludeProperty 'min', 'max', 'options', 'expiration') }
                    'Date' { return [DateField]($J | Select-Object -ExcludeProperty 'min', 'max', 'options', 'linkable_id') }
                    'Number' { return [NumberField]($J | Select-Object -ExcludeProperty 'options', 'linkable_id', 'expiration') }
                    'Dropdown' { 
                        $J.options = $J.options -split "`n"
                        return [DropdownField]($J | Select-Object -ExcludeProperty 'min', 'max', 'linkable_id', 'expiration') 
                    }
                    Default {
                        switch ($J.field_type) {
                            'Password' { $J.field_type = 'ConfidentialText' }
                            'Email' { $J.field_type = 'CopyableText' }
                            'Website' { $J.field_type = 'Site' }
                        }
                        return [AssetField]($J | Select-Object -ExcludeProperty 'min', 'max', 'options', 'linkable_id', 'expiration')
                    }
                }
            }
        }
        else {
            if ($Label.Trim().Length -eq 0 -or $null -eq $Type) {
                Write-Error 'Label and Type are required parameters.' -ErrorAction Stop
            }
            switch ($Type){
                
                'AssetLink' { 
                    if (-not $AssetTypeId) {
                        Write-Error 'AssetTypeId is required for AssetLink fields.' -ErrorAction Stop
                    }
                    $result = [AssetLinkField]::new() 
                }
                'Date' { 
                    $result = [DateField]::new()
                    $result.Expiration = $AddToExpirations
                }
                'Number' { 
                    $result = [NumberField]::new()
                    $result.Min = $Min
                    $result.Max = $Max
                }
                'Dropdown' { 
                    if (-not $Options) {
                        Write-Error 'Options are required for Dropdown fields.' -ErrorAction Stop
                    }
                    $result = [DropdownField]::new()
                    $result.Options = $Options
                }
                Default { $result = [AssetField]::new() }
            }
            $result.Label = $Label
            $result.field_type = $Type
            $result.position = $Position
            $result.required = $Required
            $result.hint = $Hint
            $result.show_in_list = $ShowInList
            return $result
        }
    }
}