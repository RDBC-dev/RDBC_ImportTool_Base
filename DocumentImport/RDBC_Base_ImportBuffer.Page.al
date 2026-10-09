page 85150 "RDBC_Base_Related_Entries"
{
    PageType = List;
    SourceTable = "RDBC_Base_Related_Entry_Buffer";
    SourceTableTemporary = true; // Ensures the page uses temporary memory
    Caption = 'Related Entries';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    // This makes the text look like a clickable link (Cyan color)
                    Style = StandardAccent;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    begin
                        ShowRecords();
                    end;
                }
                field("No. of Entries"; Rec."No. of Entries")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        ShowRecords();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowEntries)
            {
                Caption = 'Show Related Entries';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ShowRecords();
                end;
            }
        }
    }

    var
        CurrentImportName: Text[50];
        NextEntryNo: Integer;

    // Called from your Staging Page before this page opens
    procedure SetImportName(ImportName: Text[50])
    begin
        CurrentImportName := ImportName;
    end;

    trigger OnOpenPage()
    begin
        BuildBuffer();
    end;

    // Scans tables and inserts a row if it finds related records
    local procedure BuildBuffer()
    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        GenJnlLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        VATEntry: Record "VAT Entry";

    begin
        Rec.Reset();
        Rec.DeleteAll();
        NextEntryNo := 1;

        if CurrentImportName = '' then exit;

        // --- SALES ---
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Sales Order', SalesHeader.Count());

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        InsertToBuffer('Sales Invoice', SalesHeader.Count());

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        InsertToBuffer('Sales Credit Memo', SalesHeader.Count());

        SalesShptHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Posted Sales Shipment', SalesShptHeader.Count());

        SalesInvHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Posted Sales Invoice', SalesInvHeader.Count());

        SalesCrMemoHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Posted Sales Credit Memo', SalesCrMemoHeader.Count());

        // --- PURCHASES ---
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Purchase Order', PurchHeader.Count());

        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        InsertToBuffer('Purchase Invoice', PurchHeader.Count());

        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Credit Memo");
        InsertToBuffer('Purchase Credit Memo', PurchHeader.Count());

        PurchRcptHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Posted Purchase Receipt', PurchRcptHeader.Count());

        PurchInvHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Posted Purchase Invoice', PurchInvHeader.Count());

        PurchCrMemoHdr.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Posted Purchase Credit Memo', PurchCrMemoHdr.Count());

        // --- JOURNALS & G/L ---
        GenJnlLine.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        GenJnlLine.SetFilter("Document Type", '<>%1', GenJnlLine."Document Type"::Payment);
        InsertToBuffer('General Journal Line', GenJnlLine.Count());

        GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Payment);
        InsertToBuffer('Payment Journal Line', GenJnlLine.Count());

        GLEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('G/L Entry', GLEntry.Count());

        // --- SUBLEDGERS ---
        CustLedgEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Customer Ledger Entry', CustLedgEntry.Count());

        VendLedgEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Vendor Ledger Entry', VendLedgEntry.Count());

        BankAccLedgEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('Bank Account Ledger Entry', BankAccLedgEntry.Count());

        // VAT ENTRY 
        VATEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
        InsertToBuffer('VAT Entry', VATEntry.Count());


        if Rec.FindFirst() then;
    end;

    local procedure InsertToBuffer(TableName: Text[250]; RecordCount: Integer)
    begin
        if RecordCount <= 0 then exit;

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec."Table Name" := TableName;
        Rec."No. of Entries" := RecordCount;
        Rec."Data Import Name" := CurrentImportName;
        Rec.Insert();

        NextEntryNo += 1;
    end;

    // Opens the specific page based on what line the user clicks
    local procedure ShowRecords()
    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        GenJnlLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        VATEntry: Record "VAT Entry";

    begin
        case Rec."Table Name" of
            'Sales Order':
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Sales Order List", SalesHeader);
                end;
            'Sales Invoice':
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                    SalesHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Sales Invoice List", SalesHeader);
                end;
            'Posted Sales Shipment':
                begin
                    SalesShptHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Posted Sales Shipments", SalesShptHeader);
                end;
            'Posted Sales Invoice':
                begin
                    SalesInvHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Posted Sales Invoices", SalesInvHeader);
                end;
            'Sales Credit Memo':
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
                    SalesHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Sales Credit Memos", SalesHeader);
                end;
            'Posted Sales Credit Memo':
                begin
                    SalesCrMemoHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Posted Sales Credit Memos", SalesCrMemoHeader);
                end;
            'Purchase Order':
                begin
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                    PurchHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Purchase Order List", PurchHeader);
                end;
            'Purchase Invoice':
                begin
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
                    PurchHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Purchase Invoices", PurchHeader);
                end;
            'Purchase Credit Memo':
                begin
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Credit Memo");
                    PurchHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Purchase Credit Memos", PurchHeader);
                end;
            'Posted Purchase Receipt':
                begin
                    PurchRcptHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Posted Purchase Receipts", PurchRcptHeader);
                end;
            'Posted Purchase Invoice':
                begin
                    PurchInvHeader.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Posted Purchase Invoices", PurchInvHeader);
                end;
            'Posted Purchase Credit Memo':
                begin
                    PurchCrMemoHdr.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Posted Purchase Credit Memos", PurchCrMemoHdr);
                end;
            'General Journal Line':
                begin
                    GenJnlLine.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    GenJnlLine.SetFilter("Document Type", '<>%1', GenJnlLine."Document Type"::Payment);
                    Page.Run(Page::"General Journal", GenJnlLine);
                end;
            'Payment Journal Line':
                begin
                    GenJnlLine.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    GenJnlLine.SetRange("Document Type", GenJnlLine."Document Type"::Payment);
                    Page.Run(Page::"General Journal", GenJnlLine);
                end;
            'G/L Entry':
                begin
                    GLEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"General Ledger Entries", GLEntry);
                end;
            'Customer Ledger Entry':
                begin
                    CustLedgEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Customer Ledger Entries", CustLedgEntry);
                end;
            'Vendor Ledger Entry':
                begin
                    VendLedgEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Vendor Ledger Entries", VendLedgEntry);
                end;
            'Bank Account Ledger Entry':
                begin
                    BankAccLedgEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"Bank Account Ledger Entries", BankAccLedgEntry);
                end;
            'VAT Entry':
                begin
                    VATEntry.SetRange("RDBC_Base_Data Import Name", CurrentImportName);
                    Page.Run(Page::"VAT Entries", VATEntry);
                end;
        end;
    end;
}