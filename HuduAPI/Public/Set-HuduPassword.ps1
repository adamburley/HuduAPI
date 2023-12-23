# URL parameter is excluded from pipeline as passing the existing object back (as of 2.27) will corrupt any existing field value. see known issues.
# password_folder_name is a read-only value

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
        [bool]$InPortal = $false,

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
        if ($CompanyId) { $updated.company_id = $CompanyId }
        if ($Password) { $updated.password = $Password }
        if ($Name) { $updated.name = $Name }
        if ($Username) { $updated.username = $Username }
        if ($OTPKey) { $updated.otp_secret = $OTPKey }
        if ($_url) { $updated.url = $_url }
        if ($Notes) { $updated.description = $Notes }
        if ($InPortal) { $updated.in_portal = $InPortal }
        if ($ParentType) { $updated.passwordable_type = $ParentType }
        if ($ParentId) { $updated.passwordable_id = $ParentId }
        if ($FolderId) { $updated.password_folder_id = $FolderId }

        $JSON = @{ 'asset_password' = $updated } | ConvertTo-Json

        Write-Verbose "JSON: $JSON"

        if ($PSCmdlet.ShouldProcess("Update existing password ID [$Id]", "Company password asset", "Update existing Hudu asset password layout via API")) {
            Invoke-HuduRequest -Method put -Resource "/api/v1/asset_passwords/$Id" -Body $JSON | Select-Object -ExpandProperty asset_password
        }
    }
}