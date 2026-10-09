table 85150 "RDBC_Base_Related_Entry_Buffer"
{
    Caption = 'Related Entries';
    TableType = Temporary; // Lives in memory only

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Table Name"; Text[250]) { }
        field(3; "No. of Entries"; Integer) { }
        field(4; "Data Import Name"; Text[50]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}