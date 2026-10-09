enum 85112 "RDBC_Base_ApplyToMatchResult"
{
    Extensible = true;
    Caption = 'Apply-to Match Result';

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; Match)
    {
        Caption = 'Match';
    }
    value(2; Ambiguous)
    {
        Caption = 'Ambiguous';
    }
}
