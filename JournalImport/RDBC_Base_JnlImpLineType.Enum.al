enum 85111 "RDBC_Base_JnlImpLineType"
{
    Extensible = true;
    Caption = 'Journal Import Line Type';
    
    value(10; " ")
    {
        Caption = '';
    }
    value(0; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(1; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(2; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
    value(3; Customer)
    {
        Caption = 'Customer';
    }
    value(4; Vendor)
    {
        Caption = 'Vendor';
    }
}