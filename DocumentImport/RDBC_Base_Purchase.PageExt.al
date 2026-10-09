#REGION PURCHASE ORDER
// Purchase Order List, Purchase Order Card, Purchase Order Line
pageextension 85101 "RDBC_Base_POListExt" extends "Purchase Order List"
{
    layout
    {
        addafter("Amount Including VAT")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85102 "RDBC_Base_POHeaderExt" extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85103 "RDBC_Base_POLineExt" extends "Purchase Order Subform"
{
    layout
    {
        addafter("Qty. Assigned")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION PURCHASE ORDER

#REGION PURCHASE INVOICE
// Purchase Invoice List, Purchase Invoice Card, Purchase Invoice Line
pageextension 85104 "RDBC_Base_PurchInvoiceListExt" extends "Purchase Invoices"
{
    layout
    {
        addafter("Amount Including VAT")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }        
    }
}   
pageextension 85105 "RDBC_Base_PurchInvoiceExt" extends "Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85106 "RDBC_Base_PurchInvExt" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("Qty. Assigned")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}

#ENDREGION PURCHASE INVOICE
#REGION PURCHASE CREDIT MEMO
// Purchase Credit Memo List, Purchase Credit Memo Card, Purchase Credit Memo Line
pageextension 85107 "RDBC_Base_PurchCrMemoListExt" extends "Purchase Credit Memos"
{
    layout
    {
        addafter("Amount Including VAT")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }        
    }
}
pageextension 85108 "RDBC_Base_PurchCrMemoExt" extends "Purchase Credit Memo"
{
    layout
    {
        addafter(DocAmount)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85109 "RDBC_Base_PurchCrMemoLineExt" extends "Purch. Cr. Memo Subform"
{
    layout
    {
        addafter("Qty. Assigned")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION PURCHASE CREDIT MEMO

#REGION POSTED PURCHASE INVOICE
pageextension 85146 "RDBC_Base_PPurchInvoiceListExt" extends "Posted Purchase Invoices"
{
    layout
    {
        addafter("Amount Including VAT")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85147 "RDBC_Base_PPurchInvoiceExt" extends "Posted Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85148 "RDBC_Base_PPurchInvExt" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}

#ENDREGION POSTED PURCHASE INVOICE

#REGION POSTED PURCHASE CREDIT MEMO
pageextension 85149 "RDBC_Base_PPurchCrMemoListExt" extends "Posted Purchase Credit Memos"
{
    layout
    {
        addafter("Amount Including VAT")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85150 "RDBC_Base_PPurchCrMemoExt" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85151 "RDBC_Base_PPurchCrMemoLineExt" extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}

#ENDREGION POSTED PUCHASE CREDIT MEMO

pageextension 85152 "RDBC_Base_PPurchRcptListExt" extends "Posted Purchase Receipts"
{
    layout
    {
        addafter("Location Code")
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85153 "RDBC_Base_PPurchRcptExt" extends "Posted Purchase Receipt"
{
    layout
    {
        addlast(General)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
pageextension 85154 "RDBC_Base_PPurchRcptLineExt" extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("RDBC_Base_Data Import Name"; Rec."RDBC_Base_Data Import Name")
            {
                Visible = true;
                ApplicationArea = All;
            }
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}