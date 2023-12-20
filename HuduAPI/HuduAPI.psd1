#
# Module manifest for module 'HuduAPI'
#
# Generated by: Luke Whitelock
#
# Generated on: 03/02/2021
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule        = '.\HuduAPI.psm1'

    # Version number of this module.
    ModuleVersion     = '2.3.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '4e0a4feb-1658-416b-b854-ab9e913a56de'

    # Author of this module
    Author            = 'Luke Whitelock'

    # Company or vendor of this module
    CompanyName       = 'MSPP'

    # Copyright statement for this module
    Copyright         = '(c) 2021 Luke Whitelock. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This module provides an interface to the Hudu Rest API further information can be found at https://github.com/lwhitelock/HuduAPI'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '7.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport =	'Get-HuduActivityLogs',
    'Get-HuduAPIKey',
    'Get-HuduAppInfo',
    'Get-HuduArticles',
    'Get-HuduAssetLayoutFieldID',
    'Get-HuduAssetLayouts',
    'Get-HuduAssets',
    'Get-HuduBaseURL',
    'Get-HuduCard',
    'Get-HuduCompanies',
    'Get-HuduCompanyFolders',
    'Get-HuduFolderCleanName',
    'Get-HuduExpirations',
    'Get-HuduFolderMap',
    'Get-HuduFolders',
    'Get-HuduIntegrationMatchers',
    'Get-HuduMagicDashes',
    'Get-HuduPasswords',
    'Get-HuduProcesses',
    'Get-HuduPublicPhotos',
    'Get-HuduRelations',
    'Get-HuduSubFolders',
    'Get-HuduUploads',
    'Get-HuduWebsites',
    'Initialize-HuduFolder',
    'Invoke-HuduRequest',
    'New-HuduAPIKey',
    'New-HuduArticle',
    'New-HuduAsset',
    'New-HuduAssetLayout',
    'New-HuduBaseURL',
    'New-HuduCompany',
    'New-HuduCustomHeaders',
    'New-HuduFolder',
    'New-HuduPassword',
    'New-HuduPublicPhoto',
    'New-HuduRelation',
    'New-HuduUpload',
    'New-HuduWebsite',
    'Remove-HuduAPIKey',
    'Remove-HuduArticle',
    'Remove-HuduAsset',
    'Remove-HuduBaseURL',
    'Remove-HuduCompany',
    'Remove-HuduCustomHeaders',
    'Remove-HuduMagicDash',
    'Remove-HuduPassword',
    'Remove-HuduPassword',
    'Remove-HuduRelation',
    'Remove-HuduUpload',
    'Remove-HuduWebsite',
    'Set-HuduArticle',
    'Set-HuduArticleArchive',
    'Set-HuduAsset',
    'Set-HuduAssetArchive',
    'Set-HuduAssetLayout',
    'Set-HuduAssetLayout',
    'Set-HuduCompany',
    'Set-HuduCompanyArchive',
    'Set-HuduFolder',
    'Set-HuduIntegrationMatcher',
    'Set-HuduMagicDash',
    'Set-HuduPassword',
    'Set-HuduPasswordArchive',
    'Set-HuduWebsite',
    'Get-HuduAssetLayout',
    'New-HuduAssetLayoutField',
    'New-NewHuduAssetLayout',
    'Get-HuduAsset'




    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @('New-ALF')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            #Prerelease = 'alpha1'
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

