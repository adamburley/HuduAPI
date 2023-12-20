## All functions

- Added pipeline management
- Returned fields use new classes - [AssetField]

## Asset layouts

- Implemented New-HuduAssetLayoutField to manage specification of asset layout fields
    - Added Alias `New-ALF` for ease of use
- Get-HuduAssetLayout
    - Renamed to follow single-noun convention for PowerShell cmdlets
    - Updated LayoutId to Id for consistency and to take advantage of pipelining from existing Layout objects
    - Added date-based search parameters
    - Fields are sorted by position in resulting layout objects
    - Normalized object returned between when Id is specified (previously returned an `asset_layout` object with the layout as a member)
- New-HuduAssetLayout
    - Rewrote New-HuduAssetLayout to take advantage of new AssetField objects
    - Rewrote catching for layout field type names to take advantage of standardization from AssetField objects.
    - Added logic to handle implicit field ordering
    - Added detection of duplicate field labels
    - Added more verbose language for -WhatIf flag
    - Added / readded handling of Active status
    - Added handling of sidebar folder ID
    - Updated most parameters to utilize defaults matching those in Hudu UI
    - Added sample autocompletions for Icon parameter
- Set-HuduAssetLayout
    - Rewrite allows combining existing with new fields - previously, fields were overwritten 
        - **Note** the way the Hudu API is currently configured, this seems to have had the effect of appending new fields, rather than removing existing fields. Likely a defensive setup given removing fields purges data within them.
        - This method more explicitly defines that relationship.
    - New implementation also safety-checks field label collisions, including between new fields and existing fields
    - Also simplifies updating fields and adding new fields in the same call
    - Added sample autocompletions for Icon parameter
    - Added verbose output of call JSON
    - New parameter: `-Put` bypasses Put-to-patch logic in cases where the existing object contains all necessary data to update the asset
    - Added more verbose language for -WhatIf flag

## Assets

- Get-HuduAsset
    - Renamed to follow single-noun convention for PowerShell cmdlets
    - Added support for last updated time bracketing
        - Added warning for undocumented HTTP 500 errors on term
    - Added parameter sets to minimize confusion when using `-Id` or `-Slug`
    - Added support for search term

## Companies

- Get-HuduCompany