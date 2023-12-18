using System;
using System.Runtime.Serialization;
using System.Collections;
using System.Collections.Generic;

public enum AssetFieldType
{
    [EnumMember(Value = "AssetTag")]
    AssetLink,
    CheckBox,
    [EnumMember(Value = "Password")]
    ConfidentialText,
    [EnumMember(Value = "Email")]
    CopyableText,
    Date,
    Dropdown,
    Embed,
    Heading,
    Number,
    Phone,
    RichText,
    [EnumMember(Value = "Website")]
    Site,
    Text
}

public class AssetField
{
    public int id; // Id for this specific asset field
    public string label; // human label for the field
    public bool show_in_list; // whether or not to show this field in the list view
    public AssetFieldType field_type;
    public bool required;
    public string hint; // hint text for the field
    public int position; // display order of the field. 1-based index
    public bool is_destroyed;
    public override string ToString()
    {
        return String.Format("AssetField: {0} ({1})", label, field_type);
    }
}

public class AssetFieldCollection : ArrayList
{
    public override int Add(object value)
    {
        if (value is AssetField assetField)
        {
            string errors = GetValidationErrors(assetField);
            if (errors != "")
            {
                throw new ArgumentException(errors);
            }
        }
        else
        {
            throw new ArgumentException("Value must be of type AssetField.");
        }
        return base.Add(value);
    }

    public override void AddRange(ICollection c)
    {
        foreach (var value in c)
        {
            if (value is AssetField assetField)
            {
                string errors = GetValidationErrors(assetField);
                if (errors != "")
                {
                    throw new ArgumentException(errors);
                }
            }
            else
            {
                throw new ArgumentException("Value must be of type AssetField.");
            }
        }
        base.AddRange(c);
    }

    private string GetValidationErrors(AssetField assetField)
    {
        string errors = "";
        if (!IsLabelUnique(assetField.label))
        {
            errors += "Field label must be unique.\n";
        }
        if (!IsPositionUnique(assetField.position) && assetField.position >= 0)
        {
            errors += "Field position must be unique and positive. Set position to 0 to automatically assign.\n";
        }
        return errors;
    }

    private bool IsPositionUnique(int position)
    {
        foreach (AssetField assetField in this)
        {
            if (assetField.position == position)
            {
                return false;
            }
        }
        return true;
    }
    private bool IsLabelUnique(string label)
    {
        foreach (AssetField assetField in this)
        {
            if (assetField.label == label)
            {
                return false;
            }
        }
        return true;
    }
    private int GetHighestPosition()
    {
        int highestPosition = 0;
        foreach (AssetField assetField in this)
        {
            if (assetField.position > highestPosition)
            {
                highestPosition = assetField.position;
            }
        }
        return highestPosition;
    }
}

public class DropdownField : AssetField
{
    // Additional properties and methods specific to OptionsField can be added here
    public string[] options; // for dropdown field, list of options
}

public class DateField : AssetField
{
    // Additional properties and methods specific to DateField can be added here
    public bool expiration; // for date fields, if this should be added to the expirations list
}

public class AssetLinkField : AssetField
{
    // Additional properties and methods specific to TextField can be added here
    public int linkable_id; // for asset link, id of the asset type this field pulls from
}

public class NumberField : AssetField
{
    // Additional properties and methods specific to NumberField can be added here
    public string min;
    public string max;
}

public class FruitClass
{
    public string[] Fruit { get; set; }

    public FruitClass()
    {
    }

    public FruitClass(string fruits)
    {
        Fruit = fruits.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
    }
}
