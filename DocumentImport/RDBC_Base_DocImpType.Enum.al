enum 85100 "RDBC_Base_DocImpType"
{
    Extensible = true;
    Caption = 'Document Import Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "PO")
    {
        Caption = 'Purchase Order';
    }
    value(2; "PI")
    {
        Caption = 'Purchase Invoice';
    }
    value(3; "PCM")
    {
        Caption = 'Purchase Credit Memo';
    }

    value(4; "SO")
    {
        Caption = 'Sales Order';
    }
    value(5; "SI")
    {
        Caption = 'Sales Invoice';
    }

    value(6; "SCM")
    {
        Caption = 'Sales Credit Memo';
    }

}