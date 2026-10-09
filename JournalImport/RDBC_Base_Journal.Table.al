tableextension 85120 RDBC_Base_JournalExt extends "Gen. Journal Line"
{
    fields
    {
        field(85100; "RDBC_Base_Data Import Name"; Text[50])
        {
            Caption = 'Data Import Name';
            Editable = false;
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
        }

        field(85101; "RDBC_Base_Data Imp. Entry No."; Integer)
        {
            Caption = 'Data Import Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }     
}

tableextension 85121 RDBC_Base_GLEntryExt extends "G/L Entry"
{
    fields
    {
        field(85100; "RDBC_Base_Data Import Name"; Text[50])
        {
            Caption = 'Data Import Name';
            Editable = false;
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
        }

        field(85101; "RDBC_Base_Data Imp. Entry No."; Integer)
        {
            Caption = 'Data Import Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }     
}

tableextension 85122 RDBC_Base_BLEntryExt extends "Bank Account Ledger Entry"
{
    fields
    {
        field(85100; "RDBC_Base_Data Import Name"; Text[50])
        {
            Caption = 'Data Import Name';
            Editable = false;
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
        }

        field(85101; "RDBC_Base_Data Imp. Entry No."; Integer)
        {
            Caption = 'Data Import Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }     
}

tableextension 85123 RDBC_Base_TaxEntryExt extends "VAT Entry"
{
    fields
    {
        field(85100; "RDBC_Base_Data Import Name"; Text[50])
        {
            Caption = 'Data Import Name';
            Editable = false;
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
        }

        field(85101; "RDBC_Base_Data Imp. Entry No."; Integer)
        {
            Caption = 'Data Import Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

tableextension 85124 RDBC_Base_CustLedgerEntryExt extends "Cust. Ledger Entry"
{
    fields
    {
        field(85100; "RDBC_Base_Data Import Name"; Text[50])
        {
            Caption = 'Data Import Name';
            Editable = false;
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
        }

        field(85101; "RDBC_Base_Data Imp. Entry No."; Integer)
        {
            Caption = 'Data Import Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

tableextension 85125 RDBC_Base_VendLedgerEntryExt extends "Vendor Ledger Entry"
{
    fields
    {
        field(85100; "RDBC_Base_Data Import Name"; Text[50])
        {
            Caption = 'Data Import Name';
            Editable = false;
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
        }

        field(85101; "RDBC_Base_Data Imp. Entry No."; Integer)
        {
            Caption = 'Data Import Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}

