pageextension 85121 RDBC_Base_GLEExt extends "General Ledger Entries"
{
    layout
    {
        addafter("Entry No.")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = True;
                ApplicationArea = All;
            }
        }
    }
}

pageextension 85122 RDBC_Base_GenJournalExt extends "General Journal"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = True;
                ApplicationArea = All;
            }
        }
    }
}

pageextension 85123 RDBC_Base_BankLedgerExt extends "Bank Account Ledger Entries"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = True;
                ApplicationArea = All;
            }
        }
    }
}

pageextension 85124 RDBC_Base_TaxLedgerExt extends "VAT Entries"
{
    layout
    {
        addafter("Type")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = True;
                ApplicationArea = All;
            }
        }
    }
}

pageextension 85125 RDBC_Base_CustLedgerExt extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Customer No.")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = True;
                ApplicationArea = All;
            }
        }
    }
}

pageextension 85126 RDBC_Base_VendLedgerExt extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Vendor No.")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = True;
                ApplicationArea = All;
            }
        }
    }
}