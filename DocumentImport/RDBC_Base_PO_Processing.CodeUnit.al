codeunit 85145 "RDBC_Base_PO_Processor"
{
    procedure Process(
        var GroupRec: Record "RDBC_Base_DocImp_Staging";
        var Staging: Record "RDBC_Base_DocImp_Staging";
        var PurchNo: Code[20]): Boolean
    var
        PurchHeader: Record "Purchase Header";
        TryFunction: Codeunit "RDBC_Base_TryCreation_PO";

    begin
        TryFunction.SetGroupRec(GroupRec);
        Commit();
        If TryFunction.Run() then begin
            PurchNo := TryFunction.GetPurchNo();
            exit(true);
        end;
        exit(false);
    end;

    procedure ShowProcessingResultForPO(DataImportName: Text[50])
    var
        PurchHeader: Record "Purchase Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if PurchHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Orders were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Orders were created successfully. \Do you want to open a list of the created orders?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Purchase Order List", PurchHeader);
            end;
        end;
    end;

}