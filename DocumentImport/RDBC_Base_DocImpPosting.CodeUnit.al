codeunit 85123 "RDBC_Base_DocImpPosting"
{
    /// <summary>
    /// Populates Gen. Journal Line fields from source Sales/Purchase Lines BEFORE posting.
    /// This ensures the Data Import Name and Entry No. are available for GL Entry creation.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure OnGenJnlLineBeforePost(var GenJournalLine: Record "Gen. Journal Line")
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
    begin
        // Skip if already populated
        if (GenJournalLine."RDBC_Base_Data Import Name" <> '') then
            exit;

        // Try to find the source Sales Line
        if SalesHeader.ReadPermission and (GenJournalLine."Document No." <> '') then begin
            SalesHeader.Reset();
            SalesHeader.SetRange("Posting No.", GenJournalLine."Document No.");
            if SalesHeader.FindFirst() then begin
                GenJournalLine."RDBC_Base_Data Import Name" := SalesHeader."RDBC_Base_Data Import Name";
                exit;
            end;

            SalesHeader.Reset();
            SalesHeader.SetRange("No.", GenJournalLine."Document No.");
            if SalesHeader.FindFirst() then begin
                GenJournalLine."RDBC_Base_Data Import Name" := SalesHeader."RDBC_Base_Data Import Name";
            end;
        end;


        // Try to find the source Purchase Line
        if PurchHeader.ReadPermission and (GenJournalLine."Document No." <> '') then begin
            PurchHeader.Reset();
            PurchHeader.SetRange("Posting No.", GenJournalLine."Document No.");
            if PurchHeader.FindFirst() then begin
                GenJournalLine."RDBC_Base_Data Import Name" := PurchHeader."RDBC_Base_Data Import Name";
                exit;
            end;

            PurchHeader.Reset();
            PurchHeader.SetRange("No.", GenJournalLine."Document No.");
            if PurchHeader.FindFirst() then begin
                GenJournalLine."RDBC_Base_Data Import Name" := PurchHeader."RDBC_Base_Data Import Name";
            end;
        end;
    end;

    /// <summary>
    /// Transfers custom fields from Gen. Journal Line to GL Entry during posting.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure OnGLEntryCopyFromGenJnlLine(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
    end;

    // /// Transfers custom fields from Gen. Journal Line to VAT Entry during posting.
    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure OnVATEntryCopyFromGenJnlLine(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
    end;

    // Transfers custom fields from Gen. Journal Line to Customer and Vendor Ledgers during posting.
    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure OnCustLedgerEntryCopyFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure OnVendLedgerEntryCopyFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."RDBC_Base_Data Import Name" := GenJournalLine."RDBC_Base_Data Import Name";
    end;


}