#REGION PURCHASE HEADER
tableextension 85100 "RDBC_Base_PurchHeaderExt" extends "Purchase Header"
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
    }
}

tableextension 85101 "RDBC_Base_PurchLineExt" extends "Purchase Line"
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
            DataClassification = SystemMetadata;
        }
    }
}
#ENDREGION PURCHASE HEADER

#REGION POSTED PURCHASE DOCUMENTS
tableextension 85102 "RDBC_Base_PurchInvHeaderExt" extends "Purch. Inv. Header"
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
    }
}

tableextension 85103 "RDBC_Base_PurchInvLineExt" extends "Purch. Inv. Line"
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
            DataClassification = SystemMetadata;
        }
    }
}

tableextension 85104 "RDBC_Base_PurchCrMemoHeaderExt" extends "Purch. Cr. Memo Hdr."
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
    }
}

tableextension 85105 "RDBC_Base_PurchCrMemoLineExt" extends "Purch. Cr. Memo Line"
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
            DataClassification = SystemMetadata;
        }
    }
}
#ENDREGION POSTED PURCHASE DOCUMENTS

tableextension 85106 "RDBC_Base_PurchRcptHeaderExt" extends "Purch. Rcpt. Header"
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
            DataClassification = SystemMetadata;
        }
    }

}

tableextension 85107 "RDBC_Base_PurchRcptLineExt" extends "Purch. Rcpt. Line"
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
            DataClassification = SystemMetadata;
        }
    }
}
