# passing an invalid password_folder_id will result in the password being created but not visible. the password page will have a at the bottom a message like: " There are passwords hidden from view because of incorrect folder IDs. Fix Passwords [link]"
# URL parameter is excluded from pipeline as passing the existing object back (as of 2.27) will corrupt any existing field value. see known issues.
# password_folder_name is a read-only value
# slug is a read-only value

function Set-HuduPassword {
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName = 'Default')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
   # [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '')]
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [int]$Id,

        [parameter(ParameterSetName='Put',ValueFromPipelineByPropertyName, Mandatory)]
        [parameter(ParameterSetName='Default',ValueFromPipelineByPropertyName)]
        [Alias('company_id')]
        [int]$CompanyId,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Username,

        [parameter(ParameterSetName='Put',ValueFromPipelineByPropertyName, Mandatory)]
        [parameter(ParameterSetName='Default',ValueFromPipelineByPropertyName)]
        [string]$Password,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('otp_secret', 'TOTP')]
        [string]$OTPKey,

        [parameter()]
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
        [int]$FolderId,

        [parameter(ParameterSetName='Put')]
        [switch]$Put
    )
    process {
        if ($Put) {
            Write-Verbose "PUT specified."
            $PSBoundParame | Select-Object -ExcludeProperty Put,id | ConvertTo-Json
#            $existing = $PSBoundParameters
            }
        else {
            # Fetching the existing layout first, so we can emulate a PATCH request.
            $existing = Get-HuduPassword -Id $Id | select -ExcludeProperty url
            #Write-Host ($password | ConvertTo-Json -Compress) -ForegroundColor Yellow
            if (-not $updated) {
                Write-Error "No password with ID [$Id] found." -ErrorAction Stop
            }
        }
        $updated = @{}
        if ($CompanyId) { $updated.company_id = $CompanyId }
        if ($Password) { $updated.password = $Password}

        if ($Name) { $updated.name = $Name }
        if ($Username) { $updated.username = $Username }
        if ($OTPKey) { $updated.otp_secret = $OTPKey }
        if ($URL) { $updated.url = $URL }
        if ($Notes) { $updated.description = $Notes }
        if ($InPortal) { $updated.in_portal = $InPortal }
        if ($ParentType) { $updated.passwordable_type = $ParentType }
        if ($ParentId) { $updated.passwordable_id = $ParentId }
        if ($FolderId) { $updated.password_folder_id = $FolderId }
        if ($PSCmdlet.ShouldProcess($Id)) {
            #Invoke-HuduRequest -Method put -Resource "/api/v1/asset_passwords/$Id" -Body $JSON
        }
    }
}