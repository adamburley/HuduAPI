function New-NewHuduAssetLayout {
    [CmdletBinding(SupportsShouldProcess)]
    # This will silence the warning for variables with Password in their name.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter()]
        [ArgumentCompletions('"fas fa-circle"','"fas fa-key"','"fas fa-envelope"','"fas fa-laptop"','"fas fa-globe"','"fas fa-user"','"fas fa-user-secret"','"fas fa-credit-card"','"fas fa-file"','"fas fa-file-alt"','"fas fa-file-archive"','"fas fa-file-audio"','"fas fa-file-code"','"fas fa-file-excel"','"fas fa-file-image"','"fas fa-file-pdf"','"fas fa-file-powerpoint"','"fas fa-file-video"','"fas fa-file-word"','"fas fa-folder"','"fas fa-folder-open"','"fas fa-folder-plus')]
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
            name = $Name
            icon = $Icon
            color = $Color
            icon_color = $IconColor
            include_passwords = $IncludePasswords
            include_photos = $IncludePhotos
            include_comments = $IncludeComments
            include_files = $IncludeFiles
            active = $Active
        }
        if ($SidebarFolderId) {
            $layout.add('sidebar_folder_id', $SidebarFolderId)
        }
        if ($Fields) {
            # Exclude ID if present and handle mismatches between front-end site and API field type labels
            $normalizedFields = $Fields | %{
                Write-Host $_.label
                $nf = $_ | select -ExcludeProperty 'id'
                $nf.field_type = switch ($nf.field_type){
                    'AssetLink' { 'AssetTag' }
                    'ConfidentialText' { 'Password'}
                    'CopyableText' { 'Email' }
                    'Site' { 'Website' }
                    Default { $nf.field_type }
                }
                if ($nf.options) { $nf.options = $nf.options -join "`n" }
                $nf
            }

            $layout.add('fields', @($normalizedFields))
        }
        $layout
    }
}

<#
id                : 34
slug              : testgetfieldtypes-5fb0e370a784
name              : testgetfieldtypes
icon              : fas fa-circle
color             : #5b17f2
icon_color        : #FFFFFF
sidebar_folder_id : 1
active            : True
include_passwords : True
include_photos    : True
include_comments  : True
include_files     : True
created_at        : 12/14/2023 9:49:43 PM
updated_at        : 12/15/2023 6:47:33 PM
#>