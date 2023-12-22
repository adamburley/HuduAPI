<#
.SYNOPSIS
Retrieves password assets from Hudu.

.DESCRIPTION
Calls Hudu API to retrieve password assets. Returned information includes sensitive information such as password and OTP secret (TOTP seed).

.PARAMETER Name
Exact name of the asset.

.PARAMETER Company
Accepts a company ID, company name, or object from Get-HuduCompany.
If name is specified it must be an exact match or it will be omitted.

.PARAMETER SearchQuery
Specifies a search query analogous to the search box in the Hudu UI.

.PARAMETER Id
ID of the password asset.

.PARAMETER Slug
URI Slug of the password asset.

.PARAMETER UpdatedAfter
Return passwords last updated after this date.

.PARAMETER UpdatedBefore
Return passwords last updated before this date.

.INPUTS
[PSCustomObject] Accepts a company object from Get-HuduCompany.

.OUTPUTS
[PSCustomObject] Password asset object, in the case of a single result.
[PSCustomObject[]] Array of password asset objects.
See NOTES for more information on specific object properties that may be returned.

.EXAMPLE
Get-HuduPassword
Retrieves all asset passwords.

.EXAMPLE
Get-HuduPassword -Name "Database Password"
Retrieves all passwords with the name "Database Password".

.EXAMPLE
Get-HuduPassword -Company "Contoso"
Retrieves all passwords associated with the company named "Contoso".

.EXAMPLE
$company | Get-HuduPassword -SearchQuery 'Office 365'
Retrieves all passwords associated with the company represented by $company that contain the term 'Office 365'.

.NOTES
This function requires an API key with the "Password Access" key modifier. See Hudu > Admin > API.

Some properties of passwords exposed in the Hudu UI are not currently returned by the API. These include:
- Color
- Tags
- Dark Web Alert
- URL - website link associated with the password

Some properties in the API are not definied or are not clearly named:
- url: This is the fully-qualified URL for the password asset. It is NOT the URL as defined in the Hudu UI.
- password_type: Unclear what this is for. Always blank in Get calls
#>
function Get-HuduPassword {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [string]  $Name,
        [parameter(ValueFromPipeline)]
        [object]  $Company,
        [string]  $SearchQuery,
        [parameter(ParameterSetName = 'Id')]
        [int]     $Id,
        [parameter(ParameterSetName = 'Slug')]
        [string]  $Slug,
        [DateTime]$UpdatedAfter,
        [DateTime]$UpdatedBefore
    )
    process {
        if ($Id)      { return Invoke-HuduRequest -Method get -Resource "/api/v1/asset_passwords/$id"                        | Select-Object -ExpandProperty asset_password  }
        if ($Slug)    { return Invoke-HuduRequest -Method get -Resource "/api/v1/asset_passwords/" -Params @{ slug = $Slug } | Select-Object -ExpandProperty asset_passwords }
        if ($Company) {
            $companyId = switch ($Company.GetType()) {
                'PSCustomObject' { $Company.id }
                'int'            { $Company }
                'string'         { 
                        if (($cObj = Get-HuduCompany -Name $Company) -and $cObj.Count -eq 1) { $cObj.id }
                        else {
                            Write-Warning "Unable to identify company '$Company' or more than one result returned. Omitting from call."
                            $null
                        }
                    }
                Default { Write-Warning 'Unable to determine value of -Company parameter. Omitting from call.'; $null }
            }
        }
        if ($UpdatedAfter -or $UpdatedBefore) {
            $afterString  = $UpdatedAfter  ? $UpdatedAfter.ToString('o')  : (Get-Date).AddYears(-20).ToString('o')
            $beforeString = $UpdatedBefore ? $UpdatedBefore.ToString('o') : (Get-Date).ToString('o')
            $updatedAt    = "$afterString,$beforeString"
        }
        $Params = @{}
        if ($Name)        { $Params.name       = $Name        }
        if ($companyId)   { $Params.company_id = $companyId   }
        if ($updatedAt)   { $Params.updated_at = $updatedAt   }
        if ($SearchQuery) { $Params.search     = $SearchQuery }

        Write-Verbose "Request parameters: $($Params | ConvertTo-Json -Depth 3 -Compress)"

        $HuduRequest = @{
            Method   = 'GET'
            Resource = '/api/v1/asset_passwords'
            Params   = $Params
        }
        return Invoke-HuduRequestPaginated -HuduRequest $HuduRequest -Property 'asset_passwords'
    }
}