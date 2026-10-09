table 85100 "RDBC_Base_DocImp_Staging"
{
    DataClassification = CustomerContent;
    Caption = 'RDBC Document Import Staging Table';
    DataCaptionFields = "Data Import Name", "Document Import Type";


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Document Import Type"; Enum "RDBC_Base_DocImpType") { DataClassification = CustomerContent; }
        field(3; "Posting Date"; Date) { DataClassification = CustomerContent; }
        field(4; "Document Date"; Date) { DataClassification = CustomerContent; }
        field(5; "Business Relation Type"; Enum "RDBC_Base_BusRelType") { DataClassification = CustomerContent; }
        field(6; "Business Relation No."; Code[20]) { DataClassification = CustomerContent; }
        field(7; "External Document No."; Code[35]) { DataClassification = CustomerContent; }
        field(8; "Tax Liable"; Boolean) { DataClassification = CustomerContent; }
        field(9; "Tax Area Code"; Code[20]) { DataClassification = CustomerContent; }
        field(10; Type; Enum "RDBC_Base_DocImpLineType") { DataClassification = CustomerContent; }
        field(11; "No."; Code[20]) { DataClassification = CustomerContent; }
        field(12; Description; Text[100]) { DataClassification = CustomerContent; }
        field(13; "Location Code"; Code[10]) { DataClassification = CustomerContent; }
        field(14; Quantity; Decimal) { DataClassification = CustomerContent; }
        field(15; "Unit of Measure"; Code[10]) { DataClassification = CustomerContent; }
        field(16; "Unit Cost/Price"; Decimal) { DataClassification = CustomerContent; }
        field(17; "Line Amount"; Decimal) { DataClassification = CustomerContent; }
        field(18; "Tax Group Code"; Code[20]) { DataClassification = CustomerContent; }
        field(19; "Shortcut Dimension 1"; Code[20]) { DataClassification = CustomerContent; }
        field(20; "Shortcut Dimension 2"; Code[20]) { DataClassification = CustomerContent; }
        field(21; "Shortcut Dimension 3"; Code[20]) { DataClassification = CustomerContent; }
        field(22; "Shortcut Dimension 4"; Code[20]) { DataClassification = CustomerContent; }
        field(23; "Shortcut Dimension 5"; Code[20]) { DataClassification = CustomerContent; }
        field(24; "Shortcut Dimension 6"; Code[20]) { DataClassification = CustomerContent; }
        field(25; "Shortcut Dimension 7"; Code[20]) { DataClassification = CustomerContent; }
        field(26; "Shortcut Dimension 8"; Code[20]) { DataClassification = CustomerContent; }
        field(27; "Data Import Name"; Text[50]) { DataClassification = CustomerContent; }
        field(28; Validated; Boolean) { DataClassification = CustomerContent; }
        field(29; "Last Validation Error"; Text[1024]) { DataClassification = CustomerContent; }
        field(30; Processed; Boolean) { DataClassification = CustomerContent; }
        field(31; "Last Processing Error"; Text[1024]) { DataClassification = CustomerContent; }
        field(32; Posted; Boolean) { DataClassification = CustomerContent; }
        field(33; "Document Created"; Code[20]) { DataClassification = CustomerContent; }
        field(34; "Line Discount %"; Decimal) { DataClassification = CustomerContent; }
        field(40; "Apply to Document"; Text[50]) { DataClassification = CustomerContent; }

    }

    keys
    {
        key(PK; "Entry No.")
        { Clustered = true; }
        key(DataImport; "Data Import Name") { }
        key(DocGroup; "Data Import Name", "Document Import Type", "Business Relation No.", "External Document No.") { }
    }
}