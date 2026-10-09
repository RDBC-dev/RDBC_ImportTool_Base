#REGION SALES ORDER
// Sales Order list, Sales Order, Sales Invoice, Sales Credit Memo and posted equivalents
pageextension 85111 "RDBC_Base_SalesOrderListExt" extends "Sales Order List"
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
pageextension 85112 "RDBC_Base_SalesOrderExt" extends "Sales Order"
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
pageextension 85113 "RDBC_Base_SalesLineExt" extends "Sales Order Subform"
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
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION SALES ORDER

#REGION SALES INVOICE
// Sales Invoice List, Sales Invoice Card, Sales Invoice Line
pageextension 85114 "RDBC_Base_SalesInvoiceListExt" extends "Sales Invoice List"
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
pageextension 85115 "RDBC_Base_SalesInvoiceExt" extends "Sales Invoice"
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
pageextension 85116 "RDBC_Base_SalesInvoiceLineExt" extends "Sales Invoice Subform"
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
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION SALES INVOICE

#REGION SALES CREDIT MEMO
// Sales Credit Memo List, Sales Credit Memo Card, Sales Credit Memo Line
pageextension 85117 "RDBC_Base_SalesCrMemoListExt" extends "Sales Credit Memos"
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
pageextension 85118 "RDBC_Base_SalesCrMemoExt" extends "Sales Credit Memo"
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
pageextension 85119 "RDBC_Base_SalesCrMemoLineExt" extends "Sales Cr. Memo Subform"
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
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION SALES CREDIT MEMO

#REGION POSTED SALES INVOICE
pageextension 85140 "RDBC_Base_PSalesInvoiceListExt" extends "Posted Sales Invoices"
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
pageextension 85141 "RDBC_Base_PSalesInvoiceExt" extends "Posted Sales Invoice"
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
pageextension 85142 "RDBC_Base_PSalesInvoiceLineExt" extends "Posted Sales Invoice Subform"
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
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION POSTED SALES INVOICE

#REGION POSTED SALES CREDIT MEMO
pageextension 85143 "RDBC_Base_PSalesCrMemoListExt" extends "Posted Sales Credit Memos"
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
pageextension 85144 "RDBC_Base_PSalesCrMemoExt" extends "Posted Sales Credit Memo"
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
pageextension 85145 "RDBC_Base_PSalesCrMemoLineExt" extends "Posted Sales Cr. Memo Subform"
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
            field("RDBC_Base_Data Imp. Entry No."; Rec."RDBC_Base_Data Imp. Entry No.")
            {
                Visible = true;
                ApplicationArea = All;
            }
        }
    }
}
#ENDREGION POSTED SALES CREDIT MEMO

pageextension 85155 "RDBC_Base_PSalesShipListExt" extends "Posted Sales Shipments"
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
pageextension 85156 "RDBC_Base_PSalesShipExt" extends "Posted Sales Shipment"
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
pageextension 85157 "RDBC_Base_PSalesShipLineExt" extends "Posted Sales Shipment Lines"
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