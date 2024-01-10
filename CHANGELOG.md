## Functions
- [ ] **[Private Functions](#private-functions)**
    - [ ] Find-ObjectIdByReference 🆕
    - [ ] Convert-HuduAssetLayoutFieldObjectToAPIFormat 🆕
    - [ ] ⚠️ ~~Get-HuduCompanyFolders~~ *supersceded*
    - [ ] ⚠️ ~~Get-HuduFolderCleanName~~ *supersceded*
    - [ ] ⚠️ ~~Get-HuduSubfolders~~ *supersceded*
    - [X] Get-HuduFolderRecursion 🆕
- [ ] **[Miscellaneous](#misc-functions)**
    - [X] Get-HuduActivityLog
    - [ ] Get-HuduAppInfo
    - [ ] Get-HuduCard
    - [X] Get-HuduCardJumplink 🆕
    - [ ] Get-HuduExpirations
    - [X] Start-HuduExport 🆕
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
    - [X] Get-HuduAssetTemplate 🆕
    - [X] New-HuduAsset
    - [X] Get-HuduAsset
    - [X] Set-HuduAsset
    - [ ] ⚠️ ~~Set-HuduAssetArchive~~ *supersceded*
    - [ ] Remove-HuduAsset
    - [ ] Restore-HuduAsset 🆕
- [ ] **[Companies](#companies)**
    - [X] Get-HuduCompanyJumplink 🆕
    - [ ] New-HuduCompany
    - [X] Get-HuduCompany
    - [ ] Set-HuduCompany
    - [ ] ⚠️ ~~Set-HuduCompanyArchive~~ *supersceded*
    - [ ] Remove-HuduCompany
    - [ ] Restore-HuduCompany 🆕
- [ ] **[Folders](#folders)**
    - [ ] ⚠️ ~~Get-HuduFolderMap~~ *supersceded*
    - [X] Get-HuduFolder
    - [ ] ⚠️ ~~Initialize-HuduFolder~~ *supersceded*
    - [ ] Initialize-HuduFolderStructure 🆕
    - [X] New-HuduFolder
    - [ ] Set-HuduFolder

## TODO

- Refactor Find-ObjectIdByReference to check for `object_type` property as Hudu returns that with most things.
    - Asset, Article, Company
    - Not password - possibly this was the intended purpose of `password_type`
    - Added `-ReturnObject` switch. Need to refactor other functions around that capability
    - Rename function?
    - Update Start-HuduCompanyExport to remove redundant Get-HuduCompany call
- Documentation
- Add rationale for code analysis suppressions
- Pre-compile C#?
- Create more classes?
- Implement finding object id for Asset, Website
    - Add to New-HuduPassword
- Refactor Invoke-HuduRequest to return better details for calls that do not have a response (e.g. **Delete** calls)
    - Update Remove-HuduPassword and Restore-HuduPassword
- Refactor New-HuduAsset to handle fields better
- Check terminology consistency
    - AssetLayout vs Layout
- Make sure scriptstoprocess is the best way to add the classes to the PSD file.
- Refactor Find-ObjectIdByReference to handle multiple / no results better and update functions that use that function to avoid issues where an unfound reference results in making an expensive call
    - i.e. not being able to find an asset ID results in returning all assets

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
- Assets
    - If you add an asset without wrapping it in an object named 'asset' in the JSON, the asset will still be added but it will ignore any fields values. What!?
    - Likewise, not wrapping the `custom_fields` property in an array causes it to add the field but with no payload (no value).
- Expirations
    - Expiration and Resource type are case specific (asset != Asset)
- Exports
    - The sample in the API docs has the incorrect format. Correct format for a query returns HTTP 200:
```json
{
    "export": {
        "include_websites": true,
        "include_passwords": true,
        "company_id": 155,
        "format": "pdf",
        "asset_layout_ids": [
            28,
            4
        ]
    }
}
```

```json
{
  "id": 2,
  "account_id": 1,
  "s3_bucket": null,
  "s3_public": null,
  "s3_private": null,
  "s3_region": null,
  "status": "started",
  "created_at": "2024-01-03T16:30:24.324Z",
  "updated_at": "2024-01-03T16:30:24.324Z",
  "file_data": null,
  "is_pdf": true,
  "mask_passwords": null
}
```

- Folders
    - `GET /folders`
        - the `in_company` parameter is only evaluated if set to **true**.  Setting the parameter to **false** does not return only global KB folders.
        - `in_company` parameter evaluates the boolean value of JSON case-specific. `True` is not considered `true`.
    - `PUT /folders`
        - API expects updated object nested under a `folder` property in the JSON. If the object is not nested under a `folder` property in the body of the call, API does not return an error and may process with unexpected results.
        - API does not validate if the parent folder ID belongs to the same company. This allows circumstances where a folder of one company is nested under the folder of another or of the Global KB.  In this state, the error folder is visible in the parent folder view, but clicking on the link yields an error. The folder is still accessible however by manually assembling the `?company_id=[x]&folder=[y]` URI path maually.
            - In the error state, subfolders are still visible, but folder contents are not either in the original company or the new company.
            - This has been replicated to work for any company with any folder e.g. arbitrarily changing the URI returns the same folder but with the navigation trail under a different company.
            - **Possible security issue** Manually changing the `folder` parameter in the URI may allow a user to see a folder belonging to a company they do not have access delegated to, possibly only subfolder listings but possibly contents as well.
        - `parent_folder_id` does not accept `null` input. Set to `0` to make folder a first-level item.
    - `icon` API property is stored but not utilized in Hudu UI

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
- Start-HuduExport
    - New function to wrap the `/exports` and `/s3_exports` API endpoints
    - As there's no way to monitor exports from the API, added a custom LogUrl property to the returned object with a link to the log entry in the Hudu UI

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
    - Added switch `-FieldsAsHashtable`. When set, fields property is a hashtable of key-value pairs.
- Get-HuduAssetTemplate
    - New function to create a template with custom fields for that specific asset layout
    - *Fields* property includes all available fields for that layout
    - *FieldInformation* property includes field specifics (Type, Required, Options for dropdown)
- New-HuduAsset
    - Added pipeline support from objects created by Get-HuduAssetTemplate
    - `-Fields` supports both custom object from Get-HuduAssetTemplate and a standard `@{ 'fieldname' = 'fieldvalue' }` hashtable
- Set-HuduAsset
    - Added pipeline support
    - Added support to updating custom fields by hashtable and by array of objects (as returned by Get-HuduAsset)


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

## Folders

- Get-HuduFolder
    - Single-ized noun
    - Support for company objects
    - Added pipeline support from companies or folder objects
    - Added recursion support (from *Get-HuduFolderMap*)
    - Recursions now create child objects as an array under a `children` property
    - Recursion now supports recursing from a single folder
    - Added scoping Company / Global / All with workaround for `in_company` API parameter not properly handling `false` (see [api known issues](#api-known-issues))
- Put-HuduFolder
    - Added pipeline support from a folder object
    - Added support for folder objects for the `ParentFolder` parameter
    - Fixed a bug where you're not able to move folders to the root level
- Initialize-HuduFolderStructure
    - Replaces *Initialize-HuduFolder* as a way to bootstrap a hierarchy of folders
    - New structure allows multi-level stacks. Example input structure
```json
[
  {
    "name": "Servers",
    "icon": "fas fa-server",
    "description": "Documentation related to servers",
    "children": [
      {
        "name": "Windows"
      },
      {
        "name": "MacOs",
        "icon": "fas fa-apple",
        "children": [
            {
                "name": "Deployment",
                "description": "Regarding deploying MacOs servers"
            }
        ]
      }
    ]    
  },
  {
    "name": "User Onboarding"
  },
  {
    "name": "Foods",
    "children": [
        {
            "name": "Grains"
        },
        {
            "name": "Fruit"
        }
    ]
  }
]
```