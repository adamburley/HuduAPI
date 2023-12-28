<#
.SYNOPSIS
Restore a password asset from the archive.

.DESCRIPTION
Restore a password asset that has been sent to the archive.

.PARAMETER Id
Specifies the ID of the password asset to restore.

.INPUTS
[PSCustomObject]
Representation of an existing password asset.

.OUTPUTS
[PSCustomObject]
Representation of the restored password asset.

.EXAMPLE
Restore-HuduPassword -Id 12345678

.EXAMPLE
Get-HuduPassword -Id 12345678 | Restore-HuduPassword

.NOTES
Will raise an error if the password asset is not archived. There is currently no way to tell proactively if this is the case.
#>
function Restore-HuduPassword {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Id
    )
    if ($password = Get-HuduPassword -Id $Id) {
        if ($PSCmdlet.ShouldProcess("Restore password `"$($password.name)`" [$Id] from the archive", "Restore password asset", "Restore asset password via API")) {
            Invoke-HuduRequest -Method Put -Resource "/api/v1/asset_passwords/$Id/unarchive"
        }
    }
    else { Write-Error "Password asset with ID [$Id] not found. If password was permanently deleted it is not able to be restored by this function." -ErrorAction Stop }
}
