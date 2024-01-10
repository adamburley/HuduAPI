<#
.SYNOPSIS
Remove a Hudu Knowledge Base folder from a company or the Global KB.

.DESCRIPTION
Remove a Knowledge Base (KB) via Hudu API. Removing KB folders is permanent.
Contents of removed folders are placed in the root of the parent (not in any folder).

.INPUTS
[object]
A custom object created by Get-HuduFolder

.PARAMETER Id
The ID of the folder to be removed.

.PARAMETER Force
Indicates whether to force the removal without prompting for confirmation.

.EXAMPLE
Remove-HuduFolder -Id 1234

.EXAMPLE
$folder = Get-HuduFolder -Id 1234
$folder | Remove-HuduFolder

.LINK
New-HuduFolder

.LINK
Get-HuduFolder

.LINK
Set-HuduFolder
#>

function Remove-HuduFolder {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [int]$Id,

        [parameter()]
        [switch]$Force
    )    
    process {
        $_force = 'WhatIf' -in $PSBoundParameters.Keys ? $false : $Force
        if ($_force -or $PSCmdlet.ShouldProcess("Permanently Remove KB Folder [$Id]", "Knowledge Base folder [$Id]", "Permanently remove KB folder via API")) {
            Invoke-HuduRequest -Method Delete -Resource "/api/v1/folders/$Id" | Out-Null
        }
    }
}