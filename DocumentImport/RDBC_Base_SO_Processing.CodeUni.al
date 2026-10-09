codeunit 85146 "RDBC_Base_SO_Processor"
{
    procedure Process(
        var GroupRec: Record "RDBC_Base_DocImp_Staging";
        var Staging: Record "RDBC_Base_DocImp_Staging";
        var SalesNo: Code[20]): Boolean
    var

        SalesHeader: Record "Sales Invoice Header";
        TrySalesOrder: Codeunit "RDBC_Base_TryCreation_SO";

    begin
        TrySalesOrder.SetGroupRec(GroupRec);
        Commit();
        if TrySalesOrder.Run() then begin
            SalesNo := TrySalesOrder.GetSalesNo();
            exit(true);
        end;
        exit(false);
    end;

    procedure ShowProcessingResultForSO(DataImportName: Text[50])
    var
        SalesHeader: Record "Sales Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if SalesHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Orders were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Orders were created successfully.\\ Do you want to open a list of the created orders?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Sales Order List", SalesHeader);
            end;
        end;
    end;


}