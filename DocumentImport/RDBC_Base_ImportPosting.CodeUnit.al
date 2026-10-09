codeunit 85133 "RDBC_Base_ImportPostSubscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure TransferCustomFieldsToGLEntry(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
        GLEntry."RDBC_Base_Data Imp. Entry No." := GenJournalLine."RDBC_Base_Data Imp. Entry No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure TransferToBankAccLedgerEntry(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        BankAccountLedgerEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
        BankAccountLedgerEntry."RDBC_Base_Data Imp. Entry No." := GenJournalLine."RDBC_Base_Data Imp. Entry No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure TransferToCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
        CustLedgerEntry."RDBC_Base_Data Imp. Entry No." := GenJournalLine."RDBC_Base_Data Imp. Entry No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostGenJnlLine', '', false, false)]
    local procedure MarkStagingAsPosted(var GenJournalLine: Record "Gen. Journal Line")
    var
        StagingRec: Record "RDBC_Base_JnlImp_Staging";
    begin
        // 1. Skip standard BC journal lines that didn't come from your import
        if (GenJournalLine."RDBC_Base_Data Import Name" = '') or (GenJournalLine."RDBC_Base_Data Imp. Entry No." = 0) then
            exit;

        // 2. Find the corresponding entry in the Staging table
        StagingRec.Reset();
        StagingRec.SetRange("Data Import Name", GenJournalLine."RDBC_Base_Data Import Name");
        StagingRec.SetRange("Entry No.", GenJournalLine."RDBC_Base_Data Imp. Entry No.");

        if StagingRec.FindFirst() then begin
            // 3. Mark as posted if it isn't already
            if not StagingRec.Posted then begin
                StagingRec.Posted := true;
                StagingRec.Modify(); // Updates the record in the database
            end;
        end;
    end;

    // ========================================================
    // 1. SALES SHIPMENTS (From Sales Orders)
    // ========================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptLineInsert', '', false, false)]
    local procedure MarkOnSalesShipment(var SalesShptLine: Record "Sales Shipment Line"; SalesShptHeader: Record "Sales Shipment Header"; SalesLine: Record "Sales Line")
    begin
        // Passes the custom fields from the original Sales Line to our helper function
        UpdateStagingPostedStatus(SalesLine."RDBC_Base_Data Import Name", SalesLine."RDBC_Base_Data Imp. Entry No.");
    end;

    // ========================================================
    // 2. SALES INVOICES (From Orders or Direct Invoices)
    // ========================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure MarkOnSalesInvoice(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    begin
        UpdateStagingPostedStatus(SalesLine."RDBC_Base_Data Import Name", SalesLine."RDBC_Base_Data Imp. Entry No.");
    end;

    // ========================================================
    // 3. PURCHASE RECEIPTS (From Purchase Orders)
    // ========================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptLineInsert', '', false, false)]
    local procedure MarkOnPurchReceipt(var PurchRcptLine: Record "Purch. Rcpt. Line"; PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchLine: Record "Purchase Line")
    begin
        UpdateStagingPostedStatus(PurchLine."RDBC_Base_Data Import Name", PurchLine."RDBC_Base_Data Imp. Entry No.");
    end;

    // ========================================================
    // 4. PURCHASE INVOICES (From Orders or Direct Invoices)
    // ========================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvLineInsert', '', false, false)]
    local procedure MarkOnPurchInvoice(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchaseLine: Record "Purchase Line")
    begin
        UpdateStagingPostedStatus(PurchaseLine."RDBC_Base_Data Import Name", PurchaseLine."RDBC_Base_Data Imp. Entry No.");
    end;

    // ========================================================
    // 5. SALES CREDIT MEMOS
    // ========================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoLineInsert', '', false, false)]
    local procedure MarkOnSalesCrMemo(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line")
    begin
        UpdateStagingPostedStatus(SalesLine."RDBC_Base_Data Import Name", SalesLine."RDBC_Base_Data Imp. Entry No.");
    end;

    // ========================================================
    // 6. PURCHASE CREDIT MEMOS
    // ========================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoLineInsert', '', false, false)]
    local procedure MarkOnPurchCrMemo(var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line")
    begin
        UpdateStagingPostedStatus(PurchLine."RDBC_Base_Data Import Name", PurchLine."RDBC_Base_Data Imp. Entry No.");
    end;


    // ========================================================
    // HELPER FUNCTION: Updates the Staging Table
    // ========================================================
    local procedure UpdateStagingPostedStatus(ImportName: Text; EntryNo: Integer)
    var
        DocStagingRec: Record "RDBC_Base_DocImp_Staging";
    begin
        // If this line didn't come from your import, ignore it
        if (ImportName = '') or (EntryNo = 0) then
            exit;

        // Find the matching staging record
        DocStagingRec.Reset();
        DocStagingRec.SetRange("Data Import Name", ImportName);
        DocStagingRec.SetRange("Entry No.", EntryNo);

        if DocStagingRec.FindFirst() then begin
            if not DocStagingRec.Posted then begin
                DocStagingRec.Posted := true;
                DocStagingRec.Modify();
            end;
        end;
    end;
}