enum 85110 "RDBC_Base_JnlImpType"
{
    Extensible = true;
    Caption = 'Journal Import Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "General")
    {
        Caption = 'General';
    }
    value(2; "Sales Payment")
    {
        Caption = 'Sales Payment';
    }
    value(3; "Purchase Payment")
    {
        Caption = 'Purchase Payment';
    }
}