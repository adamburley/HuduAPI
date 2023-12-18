# https://blog.danskingdom.com/How-and-where-to-properly-define-classes-and-enums-in-your-PowerShell-modules/

Add-Type -TypeDefinition @"
public enum AssetFieldType {
    AssetTag,
    CheckBox,
    ConfidentialText,
    CopyableText,
    Date,
    Dropdown,
    Embed,
    Heading,
    Number,
    Phone,
    RichText,
    Site,
    Text
}
"@
