## Functions

- [X] **[Asset Layouts](#asset-layouts)**
    - [X] New-HuduAssetLayoutField 🆕
    - [X] New-HuduAssetLayout
    - [X] Get-HuduAssetLayout
    - [X] Set-HuduAssetLayout
    - [ ] ⚠️ ~~Remove-HuduAssetLayout~~ *Not currently supported by API*
- [X] **[Passwords](#passwords)**
    - [X] New-HuduPassword
    - [X] Get-HuduPassword
    - [X] Set-HuduPassword
    - [X] ⚠️ ~~Set-HuduPasswordArchive~~ *supersceded*
    - [X] Remove-HuduPassword
    - [X] Restore-HuduPassword 🆕
- [ ] **[Assets](#assets)**
    - [ ] New-HuduAsset
    - [X] Get-HuduAsset
    - [ ] Set-HuduAsset
    - [ ] ⚠️ ~~Set-HuduAssetArchive~~ *supersceded*
    - [ ] Remove-HuduAsset
    - [ ] Restore-HuduAsset 🆕
- [ ] **[Companies](#companies)**
    - [ ] Get-HuduCompanyJumplink 🆕
    - [ ] New-HuduCompany
    - [X] Get-HuduCompany
    - [ ] Set-HuduCompany
    - [ ] ⚠️ ~~Set-HuduCompanyArchive~~ *supersceded*
    - [ ] Remove-HuduCompany
    - [ ] Restore-HuduCompany 🆕

## TODO

- Documentation
- Add rationale for code analysis suppressions
- Pre-compile C#?
- Create more classes?
- Implement finding object id for Asset, Website
    - Add to New-HuduPassword
- Refactor Invoke-HuduRequest to return better details for calls that do not have a response (e.g. **Delete** calls)
    - Update Remove-HuduPassword and Restore-HuduPassword

## API Known Issues

- Overall
    - Slug is a read-only value. It is ignored if set in POST or PUT calls.
    - Folder names or parent names are generally read-only. To update, update the folder or parent ID value.

- Layouts
    - Layout field types are case-specific. Passing an incorrectly-cased layout field type can corrupt the layout

- Passwords
    - API calls that return a password object will include the asset full name in the `url` field rather than the `url` specified as a link in the body.
        - However, you may pass `url` in a New or Update call and it will update the correct field
    - passing an invalid `password_folder_id` will result in the password being created or updated, but not visible. the password page will have a at the bottom a message like: " There are passwords hidden from view because of incorrect folder IDs. Fix Passwords [link]"


## All functions

- Renamed to follow single-noun convention for PowerShell cmdlets
- Made call parameter definition more consistent (previously a variety of options was used, modifying custom objects, re-defining, etc.)
- Added pipeline management
- Returned fields use new classes - [AssetField]
- Linting and updated / expanded documentation

## Private Functions

- Convert-HuduAssetLayoutFieldObjectToAPIFormat
- Find-ObjectIdByReference
-

## Misc functions

- Get-HuduActivityLog
    - Added more output for `-Verbose`
    - Added argument completions for `-ResourceType` and `-ActionMessage` based on sample data
    - Linting

## Asset layouts

- Implemented New-HuduAssetLayoutField to manage specification of asset layout fields
    - Added Alias `New-ALF` for ease of use
- Get-HuduAssetLayout
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
    - Added pipeline support from both Company objects and Layout objects
    - Added support for last updated time bracketing
        - Added warning for undocumented HTTP 500 errors on term
    - Added parameter sets to minimize confusion when using `-Id` or `-Slug`
    - Added support for search term, updated before / updated after
    - Documentation includes notes on oddities such as the returned *url* being to the password, not the passworded thing.

## Passwords
- Get-HuduPassword
    - Added pipeline support from Company objects
    - Fixed inconsistency between returned object when specifying `-Id`
    - Added parameter sets to minimize confusion when using `-Id` or `-Slug`
    - Converted to using a single-result call when specifying `-Slug`
- Set-HuduPassword
    - ~~Added `-Put` switch to bypass extra call `-Patch` logic~~ 
    - Validated only fields included in call are updated, so no extra calls are required to ensure non-modified fields remain the same
    - Updated logic to only include changed files
    - Updated returned object to be in same format as equivalent `Get-HuduPassword` call
- New-HuduPassword
    - Added support for objects and names in the `-Company` and `-Parent` parameters
- Remove-HuduPassword
    - This now moves password to archive by default. Reduced impact from High to Medium comisserately.
    - Added `-Permanent` switch to fully delete password asset.
    - Added confirmation step unless `-Force` is specified.
    - Added step to retrieve existing password name for use in confirmations.
- Restore-HuduPassword
    - Replaces Set-HuduPasswordArchive cmdlet

## Companies

- Get-HuduCompany
    - Added parameter sets to minimize confusion when using `-Id` or `-Slug`
