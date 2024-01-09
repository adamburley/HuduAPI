function Get-HuduFolder {
    [CmdletBinding()]
    param(
        [parameter()]
        [int]$Id,

        [parameter()]
        [string]$Name,

        [parameter()]
        [Alias('company_id')]
        [object]$Company,

        [parameter()]
        [ValidateSet('Global','Company','All')]
        [string]$Scope = 'All',

        [parameter()]
        [switch]$Recurse,

        # Company or folder
        [parameter(ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        if ($InputObject) {
            if ($InputObject.object_type -eq 'Company'){
                Write-Debug "InputObject is Company: $($InputObject.name) [$($InputObject.id)]"
                $_CompanyId = $InputObject.id
            }
            elseif ($InputObject | Get-Member -Name 'parent_folder_id') {
                Write-Debug "InputObject is Folder: $($InputObject.name) [$($InputObject.id)]"
                $_id = $InputObject.id
            }
        }
        if ($Id) { $_Id = $Id }
        if ($Company){
            $_CompanyId = $Company | Find-ObjectIdByReference -Type Company
        }

        if ($_Id) {
            $result = Invoke-HuduRequest -Method get -Resource "/api/v1/folders/$_Id" | Select-Object -ExpandProperty Folder
        } else {
            $HuduRequest = @{
                Method   = 'GET'
                Resource = '/api/v1/folders'
                Params   = @{
                    company_id = $_CompanyId
                    name       = $Name
                    in_company = $Scope -eq 'Company' ? 'true' : 'false'
                }
            }
            Write-Verbose "Request Parameters: $($HuduRequest | ConvertTo-Json -Depth 4)"
            $result = Invoke-HuduRequestPaginated -HuduRequest $HuduRequest -Property folders
            if ($Scope -eq 'Global') { # Workaround for known issue where in_company = false returns company folders
                $result = $result | Where-Object { $null -eq $_.company_id }
            }
        }
        if (-not $Recurse) { return $result}
        else {
            if ($_id) {
                $recursionParents = $result
                $recursionPool = $null -eq $result.company_id ? (Get-HuduFolder -Scope Global) : (Get-HuduFolder -Company $result.company_id)
                Write-Debug "Recursion from Id. Selecting from $($recursionPool.count) folders in pool"
            } elseif ($Name) {
                $recursionParents = $result
                $recursionPool = $result | Select-Object -ExpandProperty company_id -Unique | ForEach-Object { Get-HuduFolder -Company $_ }
                if ($null -in $result.company_id) { $recursionPool += Get-HuduFolder -Scope Global }
                Write-Debug "Recursion from Name. Found $($recursionPool.count) folders in pool"
            }
            else { # Recursing from company, global, or all top level. We can use the pool we have.
                $recursionParents = $result | Where-Object { $null -eq $_.parent_folder_id }
                $recursionPool = $result | Where-Object { $null -ne $_.parent_folder_id }
                Write-Debug "Recursion from Company, Global, or All. Found $($recursionPool.count) folders in pool"
            }

            Write-Debug "Recursion Parents: $($recursionParents.name -join ',')"
            Write-Debug "Recursion pool: $($recursionPool.name -join ',')"
            
            foreach ($folder in $recursionParents){
                $folder | Add-Member -MemberType NoteProperty -Name children -Value @(($folder | Get-HuduFolderRecursion -RecursionPool $recursionPool))
            }
            return $recursionParents
        }
    }
}