table 85111 "RDBC_Base_JnlImp_Staging"
{
    DataClassification = CustomerContent;
    Caption = 'RDBC Journal Import Staging Table';
    DataCaptionFields = "Data Import Name", "Journal Import Type";


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Journal Import Type"; Enum "RDBC_Base_JnlImpType") { DataClassification = CustomerContent; }
        field(3; "Journal Batch Name"; Code[10]) { DataClassification = CustomerContent; }
        field(4; "Posting Date"; Date) { DataClassification = CustomerContent; }
        field(5; "Document No."; Code[20]) { DataClassification = CustomerContent; }
        field(6; Type; Enum "RDBC_Base_JnlImpLineType") { DataClassification = CustomerContent; }
        field(7; "No."; Code[20]) { DataClassification = CustomerContent; }
        field(8; Description; Text[100]) { DataClassification = CustomerContent; }
        field(9; "Currency Code"; Code[10]) { DataClassification = CustomerContent; }
        field(10; "Amount"; Decimal) { DataClassification = CustomerContent; }
        field(11; "Amount LCY"; Decimal) { DataClassification = CustomerContent; }
        field(12; "Bal. Account Type"; Enum "RDBC_Base_JnlImpLineType") { DataClassification = CustomerContent; }
        field(13; "Bal. Account No."; Code[20]) { DataClassification = CustomerContent; }
        field(14; "Shortcut Dimension 1"; Code[20]) { DataClassification = CustomerContent; }
        field(15; "Shortcut Dimension 2"; Code[20]) { DataClassification = CustomerContent; }
        field(16; "Shortcut Dimension 3"; Code[20]) { DataClassification = CustomerContent; }
        field(17; "Shortcut Dimension 4"; Code[20]) { DataClassification = CustomerContent; }
        field(18; "Shortcut Dimension 5"; Code[20]) { DataClassification = CustomerContent; }
        field(19; "Shortcut Dimension 6"; Code[20]) { DataClassification = CustomerContent; }
        field(20; "Shortcut Dimension 7"; Code[20]) { DataClassification = CustomerContent; }
        field(21; "Shortcut Dimension 8"; Code[20]) { DataClassification = CustomerContent; }
        field(22; "Data Import Name"; Text[50]) { DataClassification = CustomerContent; }
        field(23; Validated; Boolean) { DataClassification = CustomerContent; }
        field(24; "Last Validation Error"; Text[1024]) { DataClassification = CustomerContent; }
        field(25; Processed; Boolean) { DataClassification = CustomerContent; }
        field(26; "Last Processing Error"; Text[1024]) { DataClassification = CustomerContent; }
        field(27; Posted; Boolean) { DataClassification = CustomerContent; }
        field(28; "Document Created"; Code[20]) { DataClassification = CustomerContent; }
        field(29; "Comment"; Text[250]) { DataClassification = CustomerContent; }
        // Fields 31, 33 and 35 (Additional Dimensions) are customer-specific and added by the customer extensions.
        field(37; "BU"; Code[20]) { DataClassification = CustomerContent; Caption = 'BUSINESSUNIT'; }
        field(38; "Applies-to Invoice No."; Text[100]) { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "Entry No.")
        { Clustered = true; }
    }
    trigger OnModify()
    begin
        if Rec.Posted then
            Error('You cannot modify this entry because it has already been posted.');

        if Rec.Processed then
            Error('You cannot modify this entry because it has already been processed.');
    end;

    trigger OnDelete()
    begin
        if Rec.Posted then
            Error('You cannot delete this entry because it has already been posted.');
    end;
}