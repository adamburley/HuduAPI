# passing an invalid password_folder_id will result in the password being created but not visible. the password page will have a at the bottom a message like: " There are passwords hidden from view because of incorrect folder IDs. Fix Passwords [link]"
# URL parameter is excluded from pipeline as passing the existing object back (as of 2.27) will corrupt any existing field value. see known issues.
# password_folder_name is a read-only value
# slug is a read-only value

function Set-HuduPassword {
    [CmdletBinding(ShouldProcess,DefaultParameterSetName = 'Default')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '')]
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

        [switch]$Put
    )
    process {
        $payload = @{}
        if ($Put) {
            Write-Verbose "PUT specified."
            throw 'notimplementedexception'
            }
        else {
            # Fetching the existing layout first, so we can emulate a PATCH request.
            $payload = Get-HuduPassword -Id $Id | Select-Object -ExcludeProperty id, slug, created_at, updated_at,url,password_folder_name | ConvertTo-Json | ConvertFrom-Json -AsHashtable # TODO REWRITE
            #Write-Host ($password | ConvertTo-Json -Compress) -ForegroundColor Yellow
            if (-not $payload) {
                Write-Error "No password with ID [$Id] found." -ErrorAction Stop
            }
            
        }
        if ($CompanyId) { $payload.company_id = $CompanyId }
        if ($Password) { $payload.password = $Password}

        if ($Name) { $payload.name = $Name }
        if ($Username) { $payload.username = $Username }
        if ($OTPKey) { $payload.otp_secret = $OTPKey }
        if ($URL) { $payload.url = $URL }
        if ($Notes) { $payload.description = $Notes }
        if ($InPortal) { $payload.in_portal = $InPortal }
        if ($ParentType) { $payload.passwordable_type = $ParentType }
        if ($ParentId) { $payload.passwordable_id = $ParentId }
        if ($FolderId) { $payload.password_folder_id = $FolderId }
        if ($PSCmdlet.ShouldProcess($Id)) {
            #Invoke-HuduRequest -Method put -Resource "/api/v1/asset_passwords/$Id" -Body $JSON
        }
    }
}