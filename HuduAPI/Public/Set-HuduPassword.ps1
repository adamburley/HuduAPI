<#
.SYNOPSIS
Update an existing Hudu asset password.

.DESCRIPTION
Update an existing Hudu asset password via API. Supports pipeline input from password objects returned by Get-HuduPassword.
See NOTES for important limitations of this endpoint.

.PARAMETER Id
The ID of the existing asset password.

.PARAMETER CompanyId
The ID of the company the password is under.

.PARAMETER Name
Name / label

.PARAMETER Username
The username associated with the password.

.PARAMETER Password
The password value.

.PARAMETER OTPKey
TOTP seed / OTP MFA key. Must be in base-32 hexidecimal.

.PARAMETER URL
The URL associated with the password. Note, this field is NOT currently retrievable via API (as of Hudu 2.27). See NOTES.

.PARAMETER Notes
Notes / description.

.PARAMETER InPortal
Specifies whether the password is added to the user portal.

.PARAMETER ParentType
The type of the parent the password belongs to. This is separate from an asset link.
Available options are "Asset" and "Website".

.PARAMETER ParentId
The ID of the parent asset.

.PARAMETER FolderId
The ID of the password folder. This can be a password folder belonging to the client, or a global password folder.
Password folder details are not currently retrievable via API (as of Hudu 2.27).

.INPUTS
[PSCustomObject] representation of an existing password asset.

.OUTPUTS
The updated asset password object.

.EXAMPLE
Set-HuduPassword -Id 1234 -Name "New Password" -Username "user123" -Password "P@ssw0rd" -URL "https://example.com" -Notes "This is a test password" -InPortal $true
Updates the existing password with ID 1234, setting the name, username, password, URL, notes, and making it accessible in the portal.

.NOTES
This function requires an API key with the "Password Access" key modifier. See Hudu > Admin > API.
Due to a bug in the Hudu API, the URL property cannot be retrieved. The URL returned from a GET call belongs to the password asset in Hudu, not the URL property within the asset. However, it is able to be updated through this cmdlet.
[Color] and [Tags] properties are not currently supported by the API.
#>
function Set-HuduPassword {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    # [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '')]
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [int]$Id,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('company_id')]
        [int]$CompanyId,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Username,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Password,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('otp_secret', 'TOTP')]
        [string]$OTPKey,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$URL,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('description')]
        [string]$Notes,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('in_portal')]
        [bool]$InPortal,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('passwordable_type')]
        [ValidateSet('Asset', 'Website')]
        [string]$ParentType,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('passwordable_id')]
        [int]$ParentId,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('password_folder_id')]
        [int]$FolderId
    )
    process {
        if ($URL -inotlike "$(Get-HuduBaseURL)*") {
            $_url = $URL
        }
        else { Write-Verbose "Bugged URL detected, omitting field from call." }

        $updated = @{}
        if ($CompanyId)  { $updated.company_id  = $CompanyId }
        if ($Password)   { $updated.password    = $Password  }
        if ($Name)       { $updated.name        = $Name      }
        if ($Username)   { $updated.username    = $Username  }
        if ($OTPKey)     { $updated.otp_secret  = $OTPKey    }
        if ($_url)       { $updated.url         = $_url      }
        if ($Notes)      { $updated.description = $Notes     }
        if ($null -ne $InPortal) { $updated.in_portal  = $InPortal   }
        if ($ParentType) { $updated.passwordable_type  = $ParentType }
        if ($ParentId)   { $updated.passwordable_id    = $ParentId   }
        if ($FolderId)   { $updated.password_folder_id = $FolderId   }

        $JSON = @{ 'asset_password' = $updated } | ConvertTo-Json

        Write-Verbose "JSON: $JSON"

        if ($PSCmdlet.ShouldProcess("Update existing password ID [$Id]", "Company password asset", "Update existing Hudu asset password layout via API")) {
            Invoke-HuduRequest -Method put -Resource "/api/v1/asset_passwords/$Id" -Body $JSON | Select-Object -ExpandProperty asset_password
        }
    }
}