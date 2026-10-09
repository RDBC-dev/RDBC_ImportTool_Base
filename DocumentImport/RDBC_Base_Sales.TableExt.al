#REGION SALES HEADER
tableextension 85110 "RDBC_Base_SalesHeaderExt" extends "Sales Header"
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

tableextension 85111 "RDBC_Base_SalesLineExt" extends "Sales Line"
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
#ENDREGION SALES HEADER

#REGION POSTED SALES DOCUMENTS
tableextension 85112 "RDBC_Base_PostedSalesInvExt" extends "Sales Invoice Header"
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

tableextension 85113 "RDBC_Base_PostSalesInvLineExt" extends "Sales Invoice Line"
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
tableextension 85114 "RDBC_Base_PostedSalesCrMemoExt" extends "Sales Cr.Memo Header"
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

tableextension 85115 "RDBC_Base_PostSalesCrMemoLnExt" extends "Sales Cr.Memo Line"
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
#ENDREGION POSTED SALES DOCUMENTS

tableextension 85116 "RDBC_Base_PostedSalesShipExt" extends "Sales Shipment Header"
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

tableextension 85117 "RDBC_Base_PostSalesShipLineExt" extends "Sales Shipment Line"
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