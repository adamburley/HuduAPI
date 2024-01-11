<#
    .SYNOPSIS
    Create or Update a Magic Dash item

    .DESCRIPTION
    Create or update a Magic Dash item in a company dashboard. Magic Dash items are identified by Title and Company. If an existing Magic Dash item has the same title, it is overwritten.

    .PARAMETER Company
    Company to create the dash item in. Accepts a Company object, name, or ID.

    .PARAMETER Title
    Magic dash title, appears at the top of the dash item. This is unique within a company, setting a duplicate title overwrites the existing item of the same title.
    
    .PARAMETER Icon
    An icon to display next to the Title of the magic dash item.
    This parameter supports one of two valid formats:
     - A FontAwesome icon string. Autocompletes of common values are available but any valid react-fontawesome identifier is accepted.
     - A fully qualified URL to an image icon. This is not resized unless done so with custom CSS.

    .PARAMETER Message
    Text displayed in the body of the Magic Dash item. Accepts plain text or text formatted with HTML.
    Message is mandatory and may not be an empty string.

    .PARAMETER Content
    Further content within the Magic Dash item. Accepts one of three formats:
     - A fully qualified URL. This will be rendered as a link at the bottom of the Magic Dash item, labeled "OPEN LINK"
     - Valid HTML content. This may include headers, tables, bullets, and CSS including direct styling and class tags. An "OPEN ->" link will be rendered at the bottom of the Magic Dash item, which will make the provided content visible on the page.
     - $null.  No link is rendered, the only information displayed is in Title and Message.

    .PARAMETER Shade
    Applies styling to the magic dash item. Default options are '' (No styling), 'Success' (Green background) and 'Danger' (Pink background).
    If you are utilizing custom CSS, you may specify a custom class name here. The format is
        Shade: 'bananas'
        Class Name: .custom-fast-fact.custom-fast-fact--bananas
    See Links for references to further documentation.

    .EXAMPLE
    Set-HuduMagicDash -Title 'My First Dashboard' -Company 'Test Company' -Message 'Hello, World!'

    .EXAMPLE
    $existingMagicDash | Set-HuduMagicDash -Icon 'fas fa-lemon'
    # Set a magic dash item with a FontAwesome icon

    .EXAMPLE
    $existingMagicDash | Set-HuduMagicDash -Icon 'https://example.com/image.png'
    # Set a magic dash item with a custom image icon

    .EXAMPLE
    $existingMagicDash | Set-HuduMagicDash -Content 'https://example.com'
    # Set a magic dash item with a link to a URL

    .EXAMPLE
    $existingMagicDash | Set-HuduMagicDash -Content '<h1>My First Dashboard</h1><p>Hello, World!</p>'
    # Set a magic dash item with custom HTML content
#>
function Set-HuduMagicDash {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('company_name')]
        [object]$Company,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Message,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('image_url')]
        [ArgumentCompletions('"fas fa-info-circle"', '"fas fa-circle"', '"fas fa-key"', '"fas fa-envelope"', '"fas fa-laptop"', '"fas fa-globe"', '"fas fa-user"', '"fas fa-user-secret"', '"fas fa-credit-card"', '"fas fa-file"', '"fas fa-file-alt"', '"fas fa-file-archive"', '"fas fa-file-audio"', '"fas fa-file-code"', '"fas fa-file-excel"', '"fas fa-file-image"', '"fas fa-file-pdf"', '"fas fa-file-powerpoint"', '"fas fa-file-video"', '"fas fa-file-word"', '"fas fa-folder"', '"fas fa-folder-open"', '"fas fa-folder-plus')]
        [String]$Icon = 'fas fa-info-circle',

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('content_link')]
        [String]$Content,

        [AllowNull()]
        [String]$Shade
    )
    
    $newDash = @{
        title        = $Title
        company_name = ($Company | Find-ObjectIdByReference -Type Company -ReturnObject).name
        message      = $Message
    }
    if ('Icon' -iin $PSBoundParameters.Keys) {
        if ($Icon) {
            if ([System.Uri]::IsWellFormedUriString($Icon, [System.UriKind]::Absolute)) {
                $newDash.image_url = $Icon
            }
            else {
                $newDash.icon = $Icon
            }
        }
        else {
            $newDash.icon = $null
            $newDash.image_url = $null
        }
    } 
    if ('Content' -in $PSBoundParameters.Keys) {
        if ($Content) {
            if ([System.Uri]::IsWellFormedUriString($Content, [System.UriKind]::Absolute)) {
                $newDash.content_link = $Content
            }
            else {
                $newDash.content = $Content
            }
        }
        else {
            $newDash.content_link = $null
            $newDash.content = $null
        }
    }
    if ('Shade' -in $PSBoundParameters.Keys) {
        # Allow nulling to clear
        if ($Shade) { $newDash.shade = $Shade.ToLower() }
        else { $newDash.shade = $null }
    }
    $JSON = $newDash | ConvertTo-Json -Compress

    Write-Verbose "JSON: $JSON"

    if ($PSCmdlet.ShouldProcess("Add or update Magic Dash item [$Title]")) {
        Invoke-HuduRequest -Method post -Resource '/api/v1/magic_dash' -Body $JSON
    }
}
