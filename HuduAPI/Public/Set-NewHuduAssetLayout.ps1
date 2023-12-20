function Set-NewHuduAssetLayout {
    [CmdletBinding(SupportsShouldProcess)]
    # This will silence the warning for variables with Password in their name.
    #[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    param(
        [parameter(ValueFromPipelineByPropertyName)]
        [int]$Id,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Name,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Slug,
        [parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompletions('"fas fa-circle"', '"fas fa-key"', '"fas fa-envelope"', '"fas fa-laptop"', '"fas fa-globe"', '"fas fa-user"', '"fas fa-user-secret"', '"fas fa-credit-card"', '"fas fa-file"', '"fas fa-file-alt"', '"fas fa-file-archive"', '"fas fa-file-audio"', '"fas fa-file-code"', '"fas fa-file-excel"', '"fas fa-file-image"', '"fas fa-file-pdf"', '"fas fa-file-powerpoint"', '"fas fa-file-video"', '"fas fa-file-word"', '"fas fa-folder"', '"fas fa-folder-open"', '"fas fa-folder-plus')]
        [string]$Icon,
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Color,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('icon_color')]
        [string]$IconColor,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('sidebar_folder_id')]
        [int]$SidebarFolderId,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('include_passwords')]
        [bool]$IncludePasswords,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('include_photos')]
        [bool]$IncludePhotos,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('include_comments')]
        [bool]$IncludeComments,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('include_files')]
        [bool]$IncludeFiles,
        [parameter(ValueFromPipelineByPropertyName)]
        [bool]$Active,
        [parameter(ValueFromPipelineByPropertyName)]
        [AssetField[]]$Fields,
        [parameter()]
        [switch]$Put
    )
    process {
        if ($Put) {
            Write-Verbose "PUT specified."

        }
        else {
            # Fetching the existing layout first, so we can emulate a PATCH request.
            $layout = Get-NewHuduAssetLayout -Id $Id
            if (-not $layout) {
                Write-Error "No layout with ID $Id found. Id is required to update a layout." -ErrorAction Stop
            }
            # Compare existing layout to new layout and only update changed properties.
            $layout.name =              $Name               ? $Name : $layout.name
            $layout.slug =              $Slug               ? $Slug : $layout.slug
            $layout.icon =              $Icon               ? $Icon : $layout.icon
            $layout.color =             $Color              ? $Color : $layout.color
            $layout.icon_color =        $IconColor          ? $IconColor : $layout.icon_color
            $layout.sidebar_folder_id = $SidebarFolderId    ? $SidebarFolderId : $layout.sidebar_folder_id
            $layout.include_passwords = $IncludePasswords   ? $IncludePasswords : $layout.include_passwords
            $layout.include_photos =    $IncludePhotos      ? $IncludePhotos : $layout.include_photos
            $layout.include_comments =  $IncludeComments    ? $IncludeComments : $layout.include_comments
            $layout.include_files =     $IncludeFiles       ? $IncludeFiles : $layout.include_files
            $layout.active =            $Active             ? $Active : $layout.active
            #$layout.fields = $Fields ? ($Fields | Convert-HuduAssetLayoutFieldObjectToAPIFormat) : $layout.fields
        }
        if ($Fields) {
            if ($layout.fields) { # Handle updating fields based on ID and adding new fields. Deleting will require replacing all fields with a -Put call
                $layout.fields | Where-Object { $_.id -inotin $Fields.id } | Foreach-Object { $Fields += $_ }
            }
            $layout.fields = $Fields | Convert-HuduAssetLayoutFieldObjectToAPIFormat
            # Manage field order so new fields are at the bottom
            $nextPosition = [int]($layout.fields.Position | Measure-Object -Maximum).Maximum + 1
            foreach ($field in $layout.fields) {
                if ($field.position -eq 1 -and $null -eq $field.id) {
                    $field.position = [int]$nextPosition
                    $nextPosition++
                }
            }
        }

        $JSON = @{ asset_layout = $layout } | ConvertTo-Json -Depth 10 -EnumsAsStrings

        Write-Verbose "JSON: $JSON"
        if ($PSCmdlet.ShouldProcess("Update existing asset layout ID $($layout.id): $($layout.name).", "Asset layout $($layout.name)", "Update existing Hudu asset layout via API")) {
            #Invoke-HuduRequest -Method put -Resource "/api/v1/asset_layouts/$Id" -Body $JSON

            $JSON
        }
    }
}