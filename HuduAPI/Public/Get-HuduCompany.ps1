function Get-HuduCompany {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ValueFromPipeline, ParameterSetName = 'Id')]
        [Alias('company_id')]
        [int]$Id,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Name,

        [Parameter(ParameterSetName = 'Slug')]
        [string]$Slug,
    
        [Parameter(ParameterSetName = 'Default')]
        [Alias('phone_number')]
        [string]$PhoneNumber,

        [Parameter(ParameterSetName = 'Default')]
        [string]$Website,

        [Parameter(ParameterSetName = 'Default')]
        [string]$City,

        [Parameter(ParameterSetName = 'Default')]
        [string]$State,

        [Parameter(ParameterSetName = 'Default')]
        [Alias('search')]
        [string]$SearchTerm,

        [Parameter(ParameterSetName = 'Default')]
        [Alias('id_number')]
        [string]$IdNumber,

        [Parameter(ParameterSetName = 'Default')]
        [Alias('id_in_integration')]
        [string]$IdInIntegration
    )

    process {
        if ($Id) { return Invoke-HuduRequest -Method Get -Resource "/api/v1/companies/$Id" | Select-Object -ExpandProperty company }

        $Params = @{}
        if ($Name) { $Params.name = $Name }
        if ($Slug) { $Params.slug = $Slug }
        if ($PhoneNumber) { $Params.phone_number = $PhoneNumber }
        if ($Website) { $Params.website = $Website }
        if ($City) { $Params.city = $City }
        if ($State) { $Params.state = $State }
        if ($SearchTerm) { $Params.search = $SearchTerm }
        if ($IdNumber) { $Params.id_number = $IdNumber }
        if ($IdInIntegration) { $Params.id_in_integration = $IdInIntegration }

        Write-Verbose "Request parameters: $($Params | ConvertTo-Json -Depth 3 -Compress)"

        $HuduRequest = @{
            Method   = 'GET'
            Resource = '/api/v1/companies'
            Params   = $Params
        }

        Invoke-HuduRequestPaginated -HuduRequest $HuduRequest -Property 'companies'
    }
}