<#
.SYNOPSIS
Archive or permanently delete a password asset in Hudu.

.DESCRIPTION
Move current password assets to the archive, or permanently delete them.

.PARAMETER Id
The ID of the password asset to remove or archive.

.PARAMETER Name
The name of the password asset. If not specified, the name will be retrieved from the password asset with the specified ID.

.PARAMETER Permanent
Specifies whether to permanently delete the password asset. If this switch is used, the password asset will be permanently deleted instead of being archived.

.PARAMETER Force
Specifies whether to force the deletion of the password asset without prompting for confirmation. This switch is only applicable when the Permanent switch is used.

.INPUTS
[PSCustomObject]
Representation of an existing password asset.

.OUTPUTS
None. The function does not generate any output.

.EXAMPLE
Remove-HuduPassword -Id 12345
Removes the password asset with the ID 12345 by archiving it.

.EXAMPLE
Remove-HuduPassword -Id 67890 -Permanent -Force
Permanently deletes the password asset with the ID 67890 without prompting for confirmation.
#>
function Remove-HuduPassword {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Int]$Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter()]
        [switch]$Permanent,

        [Parameter()]
        [switch]$Force
    )
    process {
        if (-not $Name) {
            $Name = (Get-HuduPassword -Id $Id).name
        }

        $spPrompt = "Move password `"$Name`" [$Id] to archive"
        if ($Permanent){
            $spPrompt = "Permanently delete password `"$Name`" [$Id]"
            if ($Force) { $spPrompt += " and do not prompt for confirmation." }
        }
        if ($PSCmdlet.ShouldProcess($spPrompt, "Company password asset", "Remove asset password via API")) {
            if ($Permanent){
                if ($Force -or $PSCmdlet.ShouldContinue("This will permanently delete the password asset `"$Name`" [$Id]. Continue?",'')){
                    Invoke-HuduRequest -Method Delete -Resource "/api/v1/asset_passwords/$Id" | Out-Null
                }
            } else{
                Invoke-HuduRequest -Method Put -Resource "/api/v1/asset_passwords/$Id/archive"
            }
        }
    }
}
