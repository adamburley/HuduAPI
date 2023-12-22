function New-HuduAssetLayout {
    [CmdletBinding(SupportsShouldProcess)]
    # This will silence the warning for variables with Password in their name.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter()]
        [ArgumentCompletions('"fas fa-circle"', '"fas fa-key"', '"fas fa-envelope"', '"fas fa-laptop"', '"fas fa-globe"', '"fas fa-user"', '"fas fa-user-secret"', '"fas fa-credit-card"', '"fas fa-file"', '"fas fa-file-alt"', '"fas fa-file-archive"', '"fas fa-file-audio"', '"fas fa-file-code"', '"fas fa-file-excel"', '"fas fa-file-image"', '"fas fa-file-pdf"', '"fas fa-file-powerpoint"', '"fas fa-file-video"', '"fas fa-file-word"', '"fas fa-folder"', '"fas fa-folder-open"', '"fas fa-folder-plus')]
        [string]$Icon = 'fas fa-circle',
        [Parameter()]
        [string]$Color = '#5b17f2',
        [Alias('icon_color')]
        [Parameter()]
        [string]$IconColor = '#FFFFFF',
        [Alias('include_passwords')]
        [bool]$IncludePasswords = $true,
        [Alias('include_photos')]
        [bool]$IncludePhotos = $true,
        [Alias('include_comments')]
        [bool]$IncludeComments = $true,
        [Alias('include_files')]
        [bool]$IncludeFiles = $true,
        [bool]$Active = $true,
        [Alias('sidebar_folder_id')]
        [ValidateRange(1, 1000)]
        [int]$SidebarFolderId, # https://hudu.ashtonsolutions.com/admin/sidebar_folders/2/edit
        [Parameter()]
        [AssetField[]]$Fields
        # Slug is omitted - does not have an effect
        # password_types is omitted - does not have an effect
    )
    process {
        $layout = [ordered]@{
            name              = $Name
            icon              = $Icon
            color             = $Color
            icon_color        = $IconColor
            include_passwords = $IncludePasswords
            include_photos    = $IncludePhotos
            include_comments  = $IncludeComments
            include_files     = $IncludeFiles
            active            = $Active
        }
        if ($SidebarFolderId) {
            $layout.add('sidebar_folder_id', $SidebarFolderId)
        }
        if ($Fields) {
            # Exclude ID if present and handle mismatches between front-end site and API field type labels
            $normalizedFields = $Fields | Convert-HuduAssetLayoutFieldObjectToAPIFormat
            if (($normalizedFields.Position | Measure-Object -Maximum).Maximum -eq 1) {
                # No position information provided, so order based on array order.
                # Note: This is likely not needed as this appears to be the default behavior of the API.
                # However JSON is specifically unordered, so this is a safeguard.
                $currentPosition = 1
                $normalizedFields | Foreach-Object {
                    $_.position = $currentPosition
                    $currentPosition++
                }
            }
            $layout.add('fields', @($normalizedFields))
        }
        $JSON = @{ asset_layout = $layout } | ConvertTo-Json -Depth 10 -EnumsAsStrings
        Write-Verbose $JSON
        if ($PSCmdlet.ShouldProcess("Create a new asset Layout in Hudu named $Name, with icon $Icon and $($Fields.Count) fields.", "$Name, with $($Fields.Count) fields.", "Create new Hudu asset layout via API")) {
            Invoke-HuduRequest -Method post -Resource '/api/v1/asset_layouts' -Body $JSON
            #$JSON
        }
    }
}