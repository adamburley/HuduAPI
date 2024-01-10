<#
    .SYNOPSIS
    Update a KB folder

    .DESCRIPTION
    Update a Knowledge Base (KB) folder under a company or the Global KB via API. Accepts a modified folder object via pipeline.

    .INPUTS
    [object]
    A custom object created by Get-HuduFolder

    .OUTPUTS
    [object]
    The updated folder object as returned by the API.

    .PARAMETER Id
    Id of the updating folder

    .PARAMETER Name
    Updated name of the folder

    .PARAMETER Icon
    Folder icon. Note, this is exposed in the API but does not appear to be used in the UI.

    .PARAMETER Description
    Folder description

    .PARAMETER ParentFolder
    Parent folder. Accepts a folder object or integer ID. Must be a valid folder ID existing within the same company.
    If an ID is specified, the folder will be retrieved from the API to compare the company ID.
    Set to 0 or $null to move the folder to the root level.

    .PARAMETER company_id
    This parameter is utilized when updating the parent folder to ensure the parent folder is in the same company.
    If not specified, the company ID will be retrieved from the API.

    .EXAMPLE
    Set-HuduFolder -Id 1 -Name 'New folder name'

    .EXAMPLE
    Set-HuduFolder -Id 1 -Description 'This is my new folder' -ParentFolder 2

    .EXAMPLE
    $folder = Get-HuduFolder -Id 1
    $folder.name = 'New folder name'
    $folder.description = 'This is my new folder'
    $parent = Get-huduFolder -Id 2
    $folder | Set-HuduFolder -ParentFolder $parent

    .NOTES
    A bug exists in the API where a parent folder can be set to a folder in a different company. This causes the folder to appear in the incorrect location and all KB articles within the folder to be unavailable.
    As a workaround, extra calls are made to the API where necessary to ensure a new parent is in the same company as the folder being updated.

    .LINK
    Get-HuduFolder

    .LINK
    New-HuduFolder
    
    #>
function Set-HuduFolder {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Int]$Id,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]$Icon,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]$Description,

        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('parent_folder_id')]
        [object]$ParentFolder,

        [parameter(ValueFromPipelineByPropertyName)]
        [int]$company_id
    )

    $updatedFolder = @{}
    if ($Name) { $updatedFolder.name = $Name }
    if ($Icon) { $updatedFolder.icon = $Icon }
    if ($Description) { $updatedFolder.description = $Description }

    if ($ParentFolder) {
        if ($company_id) {
            $_companyId = $company_id
        }
        else {
            Write-Debug "Company ID not specified, retrieving from API"
            $_companyId = (Get-HuduFolder -Id $Id).company_id
        }

        if ($ParentFolder.id) {
            $_parentFolder = $ParentFolder   
        }
        elseif ($ParentFolder -is [int]) {
            Write-Debug "ParentFolder is an integer, retrieving from API"
            $_parentFolder = Get-HuduFolder -Id $ParentFolder
        }
        else {
            Write-Error -Message "ParentFolder must be an integer or a folder object" -Category InvalidArgument
        }

        if ($_parentFolder.company_id -eq $_companyId) {
            $updatedFolder.parent_folder_id = $_parentFolder.id
        }
        else {
            $parid = $_parentFolder.company_id
            $fid = $_companyId
            Write-Error -Message "ParentFolder must be in the same company as the folder being updated. This folder: [$fid] Parent: [$parid]" -Category InvalidArgument -ErrorAction Stop
        }
    }
    elseif ('ParentFolder' -iin $PSBoundParameters.Keys) {
        # $Null or 0 passed
        $updatedFolder.parent_folder_id = 0
    }

    $JSON = @{ 'folder' = $updatedFolder } | ConvertTo-Json -Compress

    if ($PSCmdlet.ShouldProcess("Update Folder [$Id] with these settings: $JSON", "Folder", "Update folder via API")) {
        Invoke-HuduRequest -Method put -Resource "/api/v1/folders/$Id" -Body $JSON | Select-Object -ExpandProperty folder
    }
}