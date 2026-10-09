
// Rolecenter 9022
pageextension 85120 "RDBC_Base_BM_Ext" extends "Business Manager Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(DocumentImportCues; "RDBC_Base_DocImpRC_Cue")
            {
                ApplicationArea = All;
            }
        }
    }
}

// RoleCenter 9006
pageextension 85127 "RDBC_Base_PA_Ext" extends "Order Processor Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(DocumentImportCues; "RDBC_Base_DocImpRC_Cue")
            {
                ApplicationArea = All;
            }
        }
    }
}

// Rolecenter 9027
pageextension 85128 "RDBC_Base_SC_Ext" extends "Accountant Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(DocumentImportCues; "RDBC_Base_DocImpRC_Cue")
            {
                ApplicationArea = All;
            }
        }
    }
}

// Rolecenter 9007
pageextension 85129 "RDBC_Base_PurchAgent_Ext" extends "Purchasing Agent Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(DocumentImportCues; "RDBC_Base_DocImpRC_Cue")
            {
                ApplicationArea = All;
            }
        }
    }
}