function Start-HuduExport {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Company')]
    param(
        [parameter(ParameterSetName = 'Company', ValueFromPipeline, Mandatory)]
        [object]$Company,

        [parameter(ParameterSetName = 'Company', Mandatory)]
        [ValidateSet('CSV', 'PDF')]
        [string]$Format,

        [parameter(ParameterSetName = 'Company')]
        [switch]$IncludeWebsites,

        [parameter(ParameterSetName = 'Company')]
        [switch]$IncludePasswords,

        [parameter(ParameterSetName = 'S3')]
        [switch]$S3Export
    )
    process {
        if ($S3Export) {
            $message = 'Initiate a backup of Hudu data to S3 compatible endpoint preconfigured in Hudu Admin'
            $target = 'All Hudu Data'
            $resource = '/api/v1/s3_exports'
        }
        else {
            $_company = Get-HuduCompany -Id ($Company | Find-ObjectIdByReference -Type Company -ErrorAction Stop)
            $body = @{
                export = @{
                    company_id        = $_company.id
                    format            = $Format.ToLower()
                    include_websites  = [bool]$IncludeWebsites
                    include_passwords = [bool]$IncludePasswords
                }
            } | ConvertTo-Json -Depth 3 -Compress
            Write-Verbose "JSON: $body"
            $message = "Initiate an export of company data for `"$($_company.name)`", $($IncludeWebsites ? 'with' : 'without') websites and $($IncludePasswords ? 'with' : 'without') passwords."
            $target = "Company data for `"$($_company.name)`""
            $resource = '/api/v1/exports'
        }
        if ($PSCmdlet.ShouldProcess($message, $target, "Initiate an export via API")) {
            if ($result = Invoke-HuduRequest -Method Post -Resource $resource -Body $body) {
                Write-Debug "Returned object: $($result | ConvertTo-Json -Depth 3 -Compress)"
                Write-Verbose "Export [$($result.id)] initiated."
                $logUrl = "$(Get-HuduBaseURL)/admin/exports/$($result.id)"
                Write-Information "Export successfully initiated. You may monitor the status of the export in-browser at this URL: $logUrl" -InformationAction ($InformationPreference -eq [System.Management.Automation.ActionPreference]::SilentlyContinue ? [System.Management.Automation.ActionPreference]::Continue : $InformationPreference)
                $result | Add-Member -MemberType NoteProperty -Name LogUrl -Value $logUrl
                return $result
            }
        }
    }
}