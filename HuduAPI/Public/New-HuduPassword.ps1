<#
.SYNOPSIS
Create a new Hudu asset password.

.DESCRIPTION
Create a new Hudu asset password via API. Supports pipeline input from custom objects in the same format as returned by Get-HuduPassword.
See NOTES for important limitations of this endpoint.

.PARAMETER Company
Company to add the new password under. Accepts any of [PSCustomObject] representation of a company, a company ID, or a company name. Required.

.PARAMETER Name
Name / label for the new password asset. Required.

.PARAMETER Username
The username associated with the password.

.PARAMETER Password
The password value. Required.

.PARAMETER OTPKey
TOTP seed / OTP MFA key. Must be in base-32 hexidecimal.

.PARAMETER URL
The URL associated with the password.
Note, this field is NOT currently retrievable via API (as of Hudu 2.27). See NOTES.

.PARAMETER Notes
Notes / description for the password.

.PARAMETER InPortal
Specifies whether the password is added to the user portal.

.PARAMETER Parent
An identifier for a parent asset to link to. Accepts Asset and Website types.
If passing an ID or Name, -ParentType must be set.

.PARAMETER ParentType
The type of the parent the password belongs to, when adding by ID or Name
Available options are "Asset" and "Website".

.PARAMETER FolderId
The ID of the password folder. This can be a password folder belonging to the client, or a global password folder.
Password folder details are not currently retrievable via API (as of Hudu 2.27).

.INPUTS
This function does not accept any pipeline input.

.OUTPUTS
[PSCustomObject] direct rendering of the returned JSON from the API. Not that this will include the incorrect URL property.

.EXAMPLE
New-HuduPassword -Company 2 -Name "My new password" -Password "Correct-Horse-Battery-Staple"

.EXAMPLE
# Create a password entry for "My Server" asset under "Contoso, Inc."
$company = Get-HuduCompany -Name "Contoso, Inc."
$parent = Get-HuduAsset -Name "My Server" -Company $company
New-HuduPassword -Company $company -Name "My new password" -Username "user-admin" -Password "Correct-Horse-Battery-Staple" -Parent $parent

.NOTES
This function requires an API key with the "Password Access" key modifier. See Hudu > Admin > API.
Due to a bug in the Hudu API, the URL property cannot be retrieved. The URL returned from a GET call belongs to the password asset in Hudu, not the URL property within the asset. However, it is able to be set and updated through the API.
[Color] and [Tags] properties are not currently supported by the API.
The `password_type` property is omitted as it does not appear to be used.
#>
function New-HuduPassword {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    param(
        [parameter(Mandatory)]
        [Alias('company_id')]
        [object]$Company,

        [parameter(Mandatory)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Name,

        [parameter()]
        [string]$Username,

        [parameter(Mandatory)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Password,

        [parameter()]
        [Alias('otp_secret', 'TOTP')]
        [string]$OTPKey,

        [parameter()]
        [string]$URL,

        [parameter()]
        [Alias('description')]
        [string]$Notes,

        [parameter()]
        [Alias('in_portal')]
        [bool]$InPortal = $false,

        [parameter()]
        [Alias('passwordable_id')]
        [PSCustomObject]$Parent,
        
        [parameter()]
        [Alias('passwordable_type')]
        [ValidateSet('Asset', 'Website')]
        [string]$ParentType,

        [parameter()]
        [Alias('password_folder_id')]
        [int]$FolderId
    )
    process {
        if ($Parent) {
            if ($Parent.GetType().Name -eq 'PSCustomObject') {
                $_ParentType = $Parent.asset_layout_id ? 'Asset' : 'Website'
                $_ParentId = $Parent.id
            } elseif ($ParentType.Length -eq 0){
                Write-Error "ParentType must be specified when passing a parent object by ID or Name." -ErrorAction Stop
            } elseif ($Parent.GetType().Name -eq 'Int32') {
                $_ParentType = $ParentType
                $_ParentId = $Parent
            } else { throw "TODO implement passing parent by name." }
        }
        $companyId = $Company | Find-ObjectIdByReference -Type Company
        $new = @{
            'company_id' = $companyId
            'name' = $Name
            'password' = $Password
            'in_portal' = $InPortal
        }
        if ($OTPKey)     { $new.otp_secret  = $OTPKey    }
        if ($URL)       { $new.url         = $URL      }
        if ($Notes)      { $new.description = $Notes     }
        if ($_ParentType) { $new.passwordable_type  = $_ParentType }
        if ($_ParentId)   { $new.passwordable_id    = $_ParentId   }
        if ($FolderId)   { $new.password_folder_id = $FolderId   }

        $JSON = @{ 'asset_password' = $new } | ConvertTo-Json

        Write-Verbose "JSON: $JSON"

        if ($PSCmdlet.ShouldProcess("Create new password under company ID [$companyId] with name [$Name]", "Company password asset", "Create new asset password via API")) {
            Invoke-HuduRequest -Method Post -Resource "/api/v1/asset_passwords" -Body $JSON | Select-Object -ExpandProperty asset_password
        }
    }
}