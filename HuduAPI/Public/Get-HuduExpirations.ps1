function Get-HuduExpirations {
    [CmdletBinding()]
    Param (
        [Alias('company_id')]
        [object]$Company,

        [ValidateSet('undeclared', 'domain', 'ssl_certificate', 'warranty', 'asset_field', 'article_expiration',IgnoreCase=$false,ErrorMessage='Expiration type names are case-sensitive. Valid values are undeclared, domain, ssl_certificate, warranty, asset_field, and article_expiration.')]
        [Alias('expiration_type')]
        [string]$ExpirationType,

        [parameter(ValueFromPipeline)]
        [Alias('resource_id','ResourceId')]
        [object]$Resource,

        [parameter()]
        [Alias('resource_type','asset_type')]
        [ValidateSet('Article','Asset','AssetPassword','Website',IgnoreCase=$false,ErrorMessage='Resource type names are case-sensitive. Valid values are Article, Asset, and Website.')]
        [string]$ResourceType

   
    )
    process {
        if ($Resource){
            if ($Resource.object_type -and $Resource.object_type -iin @( 'Article','Asset','AssetPassword','Website' )) { # Catch asset reference objects
                $_resourceType = $Resource.object_type
                $_resourceId = $Resource.id
            } elseif ($ResourceType) {
                if ($resId = $Resource | Find-ObjectIdByReference -Type $ResourceType -ErrorAction SilentlyContinue) {
                    $_resourceType = $ResourceType
                    $_resourceId = $resId
                } else {
                    Write-Error "Unable to identify resource type for '$($Resource | ConvertTo-Json -Depth 5 -Compress)' of type $ResourceType. Resource Type is mandatory if string or INT specified for resource." -ErrorAction Stop
                }
            } else {
                Write-Error "Unable to identify resource type for '$($Resource | ConvertTo-Json -Depth 5 -Compress)' of type $ResourceType. Resource Type is mandatory if string or INT specified for resource." -ErrorAction Stop
            }
        }
        $_companyId = $Company | Find-ObjectIdByReference -Type 'Company' -ErrorAction Stop
        
        $Params = @{}
        if ($_companyId) { $Params.company_id = $_companyId }
        if ($ExpirationType) { $Params.expiration_type = $ExpirationType }
        if ($_resourceType) { $Params.resource_type = $_resourceType }
        if ($_resourceId) { $Params.resource_id = $_resourceId }
    
        $HuduRequest = @{
            Method   = 'GET'
            Resource = '/api/v1/expirations'
            Params   = $Params
        }
        Write-Verbose "Request parameters: $($Params | ConvertTo-Json -Depth 3 -Compress)"
        Invoke-HuduRequestPaginated -HuduRequest $HuduRequest
    }
}
