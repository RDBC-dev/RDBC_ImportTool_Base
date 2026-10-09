enum 85102 "RDBC_Base_DocImpLineType"
{
    Extensible = true;
    Caption = 'Document Import Line Type';

    value(10; " ")
    {
        Caption = ' ';
    }
    value(11; Comment)
    {
        Caption = 'Comment';
    }
    value(0; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; Resource)
    {
        Caption = 'Resource';
    }
    value(3; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
    value(4; "Charge (Item)")
    {
        Caption = 'Charge (Item)';
    }
}