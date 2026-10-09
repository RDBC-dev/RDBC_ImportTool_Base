codeunit 85121 "RDBC_Base_DocImpValidationMgt"
{


    // This codeunit is responsible for validating the data in the staging table after it has been imported from Excel, but before it is processed into actual documents.
    // It is called from the staging page action "Validate Lines" 
    // and also from the upload codeunit after the import is done, to provide immediate feedback on the validity of the imported data.

    // This procedure validates all unvalidated lines for a given import batch (DataImportName), counts the errors and returns the count. 
    // It also updates the staging records with validation results and error messages.
    procedure ValidateUnvalidatedLines(DataImportName: Text[50]) ErrorCount: Integer
    var
        Staging: Record "RDBC_Base_DocImp_Staging";
    begin
        ErrorCount := 0;

        Staging.SetRange(Validated, false);
        Staging.SetRange("Data Import Name", DataImportName);

        if Staging.FindSet() then
            repeat
                if not ValidateSingleLine(Staging) then
                    ErrorCount += 1;
            until Staging.Next() = 0;

        exit(ErrorCount);
    end;

    local procedure ValidateSingleLine(var Staging: Record "RDBC_Base_DocImp_Staging"): Boolean
    var
        ErrorText: Text[1024];
    begin
        ErrorText := '';

        case Staging."Document Import Type" of

            Staging."Document Import Type"::"PO":
                ValidatePO(Staging, ErrorText);

            Staging."Document Import Type"::"PI":
                //ValidateExpense(Staging, ErrorText);
                ValidatePI(Staging, ErrorText);

            Staging."Document Import Type"::"PCM":
                //ValidateExpense(Staging, ErrorText);
                ValidatePCM(Staging, ErrorText);

            Staging."Document Import Type"::"SO":
                ValidateSO(Staging, ErrorText);

            Staging."Document Import Type"::"SI":
                ValidateSI(Staging, ErrorText);

            Staging."Document Import Type"::"SCM":
                ValidateSCM(Staging, ErrorText);

        end;

        if ErrorText = '' then begin
            Staging.Validated := true;
            Staging."Last Validation Error" := '';
            Staging.Modify();
            exit(true);
        end else begin
            Staging.Validated := false;
            Staging."Last Validation Error" := ErrorText;
            Staging.Modify();
            exit(false);
        end;
    end;

    // called by staging page action, validates only the lines currently filtered in the page
    // can be used to re-validate lines after fixing errors    
    procedure ValidateAndHandleResult(var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        WorkRec: Record "RDBC_Base_DocImp_Staging";
        ErrorCount: Integer;
    begin
        WorkRec.Copy(Staging);
        WorkRec."Data Import Name" := Staging."Data Import Name";
        ErrorCount := ValidateUnvalidatedLines(Staging."Data Import Name");

        HandleValidationResult(WorkRec, ErrorCount);
    end;

    local procedure HandleValidationResult(var Staging: Record "RDBC_Base_DocImp_Staging"; ErrorCount: Integer)
    var
        FilteredRec: Record "RDBC_Base_DocImp_Staging";
    begin
        FilteredRec.Copy(Staging);

        if ErrorCount = 0 then begin
            if Confirm(
                'All lines were validated successfully.\Do you want to open validated lines?',
                false,
                'Open staging',
                'Close')
            then begin
                Staging.Reset();
                Staging.SetRange("Data Import Name", Staging."Data Import Name");
                OpenStagingProcessingView(Staging);
            end;
        end;
    end;

    // Document Type PURCHASE ORDER
    local procedure ValidatePO(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        PurchHeader: Record "Purchase Header";
        PPSetup: Record "Purchases & Payables Setup";

    begin

        ValidateDataImportName(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateVendorBusinessRelation(Staging, ErrorText);
        ValidateTaxSetup(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateLocation(Staging, ErrorText);
        ValidateUnitOfMeasure(Staging, ErrorText);
        ValidateTaxGroup(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
    end;

    // Document Type Purchase Invoice
    local procedure ValidatePI(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PPSetup: Record "Purchases & Payables Setup";

    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateVendorBusinessRelation(Staging, ErrorText);

        #Region External Document Number
        // Check unposted Purchase documents
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        PurchHeader.SetRange("Vendor Invoice No.", Staging."External Document No.");

        if PurchHeader.FindFirst() then begin
            AddError(ErrorText,
                StrSubstNo(
                    'Vendor Invoice No. %1 already exists in document %2.',
                    Staging."External Document No.",
                    PurchHeader."No."));
            exit;
        end;

        // Check posted Purchase Invoices
        PurchInvHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        PurchInvHeader.SetRange("Vendor Invoice No.", Staging."External Document No.");

        if PurchInvHeader.FindFirst() then
            AddError(ErrorText,
                StrSubstNo(
                    'Vendor Invoice No. %1 already exists in Posted Purchase Invoice %2.',
                    Staging."External Document No.",
                    PurchInvHeader."No."));

        #Endregion

        ValidateTaxSetup(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateLocation(Staging, ErrorText);
        ValidateUnitOfMeasure(Staging, ErrorText);
        ValidateTaxGroup(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
    end;

    // Document Type Purchase Credit Memo
    local procedure ValidatePCM(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        PurchHeader: Record "Purchase Header";
        PurchCMHeader: Record "Purch. Cr. Memo Hdr.";
        PurchInvHeader: Record "Purch. Inv. Header";
        PPSetup: Record "Purchases & Payables Setup";

    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateVendorBusinessRelation(Staging, ErrorText);

        #Region External Document Number
        // Check unposted Purchase documents
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Credit Memo");
        PurchHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        PurchHeader.SetRange("Vendor Cr. Memo No.", Staging."External Document No.");

        if PurchHeader.FindFirst() then begin
            AddError(ErrorText,
                StrSubstNo(
                    'Vendor Credit Memo No. %1 already exists in document %2.',
                    Staging."External Document No.",
                    PurchHeader."No."));
            exit;
        end;

        // Check posted Purchase Invoices
        PurchCMHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        PurchCMHeader.SetRange("Vendor Cr. Memo No.", Staging."External Document No.");

        if PurchCMHeader.FindFirst() then
            AddError(ErrorText,
                StrSubstNo(
                    'Vendor Credit Memo No. %1 already exists in Posted Purchase Credit Memo %2.',
                    Staging."External Document No.",
                    PurchCMHeader."No."));

        #Endregion

        // APPLY TO DOCUMENT (column 26)
        if Staging."Apply to Document" = '' then
            AddError(ErrorText, 'Apply to Document must contain a value for Purchase Credit Memos so it can be applied to an invoice when posted.')
        else
            case FindPostedPurchaseInvoice(Staging, PurchInvHeader) of
                "RDBC_Base_ApplyToMatchResult"::None:
                    AddError(ErrorText, StrSubstNo('No Posted Purchase Invoice with No. or Vendor Invoice No. (External Document No.) %1 was found for vendor %2.', Staging."Apply to Document", Staging."Business Relation No."));
                "RDBC_Base_ApplyToMatchResult"::Ambiguous:
                    AddError(ErrorText, StrSubstNo('Vendor Invoice No. %1 matches more than one Posted Purchase Invoice for vendor %2. Use the Document No. instead.', Staging."Apply to Document", Staging."Business Relation No."));
            end;

        ValidateTaxSetup(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateLocation(Staging, ErrorText);
        ValidateUnitOfMeasure(Staging, ErrorText);
        ValidateTaxGroup(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
    end;

    // Matches "Apply to Document" against the Posted Purchase Invoice's No. first, and falls back
    // to matching it against the invoice's Vendor Invoice No. (the External Document No. equivalent).
    // When resolved via the fallback field, the staging line is updated to the real No.
    local procedure FindPostedPurchaseInvoice(var Staging: Record "RDBC_Base_DocImp_Staging"; var PurchInvHeader: Record "Purch. Inv. Header"): Enum "RDBC_Base_ApplyToMatchResult"
    var
        TempPurchInvHeader: Record "Purch. Inv. Header" temporary;
        MatchPurchInvHeader: Record "Purch. Inv. Header";
    begin
        if PurchInvHeader.Get(CopyStr(Staging."Apply to Document", 1, 20)) then
            if PurchInvHeader."Buy-from Vendor No." = Staging."Business Relation No." then
                exit("RDBC_Base_ApplyToMatchResult"::Match);

        MatchPurchInvHeader.Reset();
        MatchPurchInvHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        MatchPurchInvHeader.SetRange("Vendor Invoice No.", Staging."Apply to Document");
        if MatchPurchInvHeader.FindSet() then
            repeat
                if not TempPurchInvHeader.Get(MatchPurchInvHeader."No.") then begin
                    TempPurchInvHeader := MatchPurchInvHeader;
                    TempPurchInvHeader.Insert();
                end;
            until MatchPurchInvHeader.Next() = 0;

        case TempPurchInvHeader.Count() of
            0:
                exit("RDBC_Base_ApplyToMatchResult"::None);
            1:
                begin
                    TempPurchInvHeader.FindFirst();
                    PurchInvHeader.Get(TempPurchInvHeader."No.");
                    if Staging."Apply to Document" <> PurchInvHeader."No." then begin
                        Staging."Apply to Document" := PurchInvHeader."No.";
                        Staging.Modify();
                    end;
                    exit("RDBC_Base_ApplyToMatchResult"::Match);
                end;
            else
                exit("RDBC_Base_ApplyToMatchResult"::Ambiguous);
        end;
    end;

    // Document Type Sales Order 
    local procedure ValidateSO(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        SalesHeader: Record "Sales Header";

    Begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateCustomerBusinessRelation(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateLocation(Staging, ErrorText);
        ValidateUnitOfMeasure(Staging, ErrorText);
        ValidateTaxGroup(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
    end;

    // Document Type Sales Invoice
    local procedure ValidateSI(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";

    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateCustomerBusinessRelation(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateLocation(Staging, ErrorText);
        ValidateUnitOfMeasure(Staging, ErrorText);
        ValidateTaxGroup(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
    end;

    // Document Type Sales Credit Memo
    local procedure ValidateSCM(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])

    var
        SalesHeader: Record "Sales Header";
        SalesCMHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";

    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateCustomerBusinessRelation(Staging, ErrorText);
        // APPLY TO DOCUMENT (column 26)
        if Staging."Apply to Document" = '' then
            AddError(ErrorText, 'Apply to Document must contain a value for Sales Credit Memos so it can be applied to an invoice when posted.')
        else
            case FindPostedSalesInvoice(Staging, SalesInvHeader) of
                "RDBC_Base_ApplyToMatchResult"::None:
                    AddError(ErrorText, StrSubstNo('No Posted Sales Invoice with No., External Document No. or Your Reference %1 was found for customer %2.', Staging."Apply to Document", Staging."Business Relation No."));
                "RDBC_Base_ApplyToMatchResult"::Ambiguous:
                    AddError(ErrorText, StrSubstNo('External Document No./Your Reference %1 matches more than one Posted Sales Invoice for customer %2. Use the Document No. instead.', Staging."Apply to Document", Staging."Business Relation No."));
            end;

        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateLocation(Staging, ErrorText);
        ValidateUnitOfMeasure(Staging, ErrorText);
        ValidateTaxGroup(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
    end;

    // Matches "Apply to Document" against the Posted Sales Invoice's No. first, and falls back
    // to matching it against the invoice's External Document No. or Your Reference.
    // When resolved via the fallback fields, the staging line is updated to the real No.
    local procedure FindPostedSalesInvoice(var Staging: Record "RDBC_Base_DocImp_Staging"; var SalesInvHeader: Record "Sales Invoice Header"): Enum "RDBC_Base_ApplyToMatchResult"
    var
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        MatchSalesInvHeader: Record "Sales Invoice Header";
    begin
        if SalesInvHeader.Get(CopyStr(Staging."Apply to Document", 1, 20)) then
            if SalesInvHeader."Sell-to Customer No." = Staging."Business Relation No." then
                exit("RDBC_Base_ApplyToMatchResult"::Match);

        MatchSalesInvHeader.Reset();
        MatchSalesInvHeader.SetRange("Sell-to Customer No.", Staging."Business Relation No.");
        MatchSalesInvHeader.SetRange("External Document No.", Staging."Apply to Document");
        if MatchSalesInvHeader.FindSet() then
            repeat
                if not TempSalesInvHeader.Get(MatchSalesInvHeader."No.") then begin
                    TempSalesInvHeader := MatchSalesInvHeader;
                    TempSalesInvHeader.Insert();
                end;
            until MatchSalesInvHeader.Next() = 0;

        MatchSalesInvHeader.Reset();
        MatchSalesInvHeader.SetRange("Sell-to Customer No.", Staging."Business Relation No.");
        MatchSalesInvHeader.SetRange("Your Reference", Staging."Apply to Document");
        if MatchSalesInvHeader.FindSet() then
            repeat
                if not TempSalesInvHeader.Get(MatchSalesInvHeader."No.") then begin
                    TempSalesInvHeader := MatchSalesInvHeader;
                    TempSalesInvHeader.Insert();
                end;
            until MatchSalesInvHeader.Next() = 0;

        case TempSalesInvHeader.Count() of
            0:
                exit("RDBC_Base_ApplyToMatchResult"::None);
            1:
                begin
                    TempSalesInvHeader.FindFirst();
                    SalesInvHeader.Get(TempSalesInvHeader."No.");
                    if Staging."Apply to Document" <> SalesInvHeader."No." then begin
                        Staging."Apply to Document" := SalesInvHeader."No.";
                        Staging.Modify();
                    end;
                    exit("RDBC_Base_ApplyToMatchResult"::Match);
                end;
            else
                exit("RDBC_Base_ApplyToMatchResult"::Ambiguous);
        end;
    end;




    #REGION VALIDATION PROCEDURES *************************

    // DATA IMPORT NAME
    local procedure ValidateDataImportName(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    begin
        if Staging."Data Import Name" = '' then
            AddError(ErrorText, 'Data Import Name must contain a value.');
    end;

    // POSTING AND DOCUMENT DATE
    local procedure ValidateDates(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    begin
        if Staging."Posting Date" = 0D then
            AddError(ErrorText, 'Posting Date must contain a value.');

        if Staging."Document Date" = 0D then begin
            Staging."Document Date" := Staging."Posting Date";
            Staging.Modify();
        end;
    end;

    // VENDOR NUMBER
    local procedure ValidateVendorBusinessRelation(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        Vendor: Record Vendor;
    begin
        if Staging."Business Relation Type" <> Staging."Business Relation Type"::Vendor then
            AddError(ErrorText, 'Business Relation Type must be Vendor.');

        if Staging."Business Relation No." = '' then begin
            AddError(ErrorText, 'Vendor No. must contain a value.');
            exit;
        end;

        if not Vendor.Get(Staging."Business Relation No.") then
            AddError(ErrorText, 'Vendor does not exist.')
        else
            if Vendor.Blocked <> Vendor.Blocked::" " then
                AddError(ErrorText, 'Vendor is blocked.');
    end;
    //CUSTOMER NUMBER
    local procedure ValidateCustomerBusinessRelation(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        Customer: Record Customer;
    begin
        if Staging."Business Relation Type" <> Staging."Business Relation Type"::Customer then
            AddError(ErrorText, 'Business Relation Type must be Customer.');

        if Staging."Business Relation No." = '' then begin
            AddError(ErrorText, 'Customer No. must contain a value.');
            exit;
        end;

        if not Customer.Get(Staging."Business Relation No.") then
            AddError(ErrorText, 'Customer does not exist.')
        else
            if Customer.Blocked <> Customer.Blocked::" " then
                AddError(ErrorText, 'Customer is blocked.');
    end;
    // EXTERNAL DOCUMENT NUMBER
    local procedure ValidateExternalDocumentNoExists(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    begin
        if Staging."External Document No." = '' then
            AddError(ErrorText,
                'External Document No. must contain a value.');
    end;

    local procedure ValidateExternalDocumentNo(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";

    begin
        // Check unposted Purchase documents
        case Staging."Document Import Type" of

            Staging."Document Import Type"::"PO":
                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);

            Staging."Document Import Type"::"PI":
                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);

            Staging."Document Import Type"::"PCM":
                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Credit Memo");

        end;

        // PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        PurchHeader.SetRange("Vendor Invoice No.", Staging."External Document No.");

        if PurchHeader.FindFirst() then begin
            AddError(ErrorText,
                StrSubstNo(
                    'External Document No. %1 already exists in document %2.',
                    Staging."External Document No.",
                    PurchHeader."No."));
            exit;
        end;

        // Check posted Purchase Invoices
        PurchInvHeader.SetRange("Buy-from Vendor No.", Staging."Business Relation No.");
        PurchInvHeader.SetRange("Vendor Invoice No.", Staging."External Document No.");

        if PurchInvHeader.FindFirst() then
            AddError(ErrorText,
                StrSubstNo(
                    'External Document No. %1 already exists in Posted Purchase Invoice %2.',
                    Staging."External Document No.",
                    PurchInvHeader."No."));

        // // Check unposted Sales documents
        if not (Staging."Document Import Type" in
            [Staging."Document Import Type"::"SO",
            Staging."Document Import Type"::"SI",
            Staging."Document Import Type"::"SCM"]) then
            exit;

        case Staging."Document Import Type" of

            Staging."Document Import Type"::"SO":
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);

            Staging."Document Import Type"::"SI":
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);

            Staging."Document Import Type"::"SCM":
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");

        end;
        // SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Sell-to Customer No.", Staging."Business Relation No.");
        SalesHeader.SetRange("External Document No.", Staging."External Document No.");

        if SalesHeader.FindFirst() then begin
            AddError(ErrorText,
                StrSubstNo(
                    'External Document No. %1 already exists in Sales document %2.',
                    Staging."External Document No.",
                    SalesHeader."No."));
            exit;
        end;
    end;

    // Looks up the Tax Liable and Tax Area Code that apply by default for the line's
    // Vendor/Customer. Used whenever the imported values need to fall back to the
    // Business Relation's own tax setup.
    local procedure GetDefaultTaxLiableAndArea(var Staging: Record "RDBC_Base_DocImp_Staging"; var DefaultTaxLiable: Boolean; var DefaultTaxAreaCode: Code[20])
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        case Staging."Business Relation Type" of
            Staging."Business Relation Type"::Vendor:
                if Vendor.Get(Staging."Business Relation No.") then begin
                    DefaultTaxLiable := Vendor."Tax Liable";
                    DefaultTaxAreaCode := Vendor."Tax Area Code";
                end;

            Staging."Business Relation Type"::Customer:
                if Customer.Get(Staging."Business Relation No.") then begin
                    DefaultTaxLiable := Customer."Tax Liable";
                    DefaultTaxAreaCode := Customer."Tax Area Code";
                end;
        end;
    end;

    // TAX SETUP
    local procedure ValidateTaxSetup(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        TaxArea: Record "Tax Area";
        DefaultTaxLiable: Boolean;
        DefaultTaxAreaCode: Code[20];
        PPSetup: Record "Purchases & Payables Setup";

    begin
        PPSetup.Get();
        if PPSetup."Use Vendor's Tax Area Code" then begin
            GetDefaultTaxLiableAndArea(Staging, DefaultTaxLiable, DefaultTaxAreaCode);
            If Staging."Tax Liable" <> DefaultTaxLiable then
                AddError(ErrorText, StrSubstNo('Tax Liable %1 does not match the default for the Vendor/Customer %2.', Staging."Tax Liable", Staging."Business Relation No."));
            If Staging."Tax Area Code" <> DefaultTaxAreaCode then
                AddError(ErrorText, StrSubstNo('Tax Area Code %1 does not match the default for the Vendor/Customer %2.', Staging."Tax Area Code", Staging."Business Relation No."));

        end;

        // Do NOT validate Tax Liable itself.
        // Only validate dependency.

        if Staging."Tax Liable" then begin

            if Staging."Tax Area Code" = '' then
                AddError(ErrorText, 'Tax Area Code must contain a value when Tax Liable is set.')
            else begin
                if not TaxArea.Get(Staging."Tax Area Code") then
                    AddError(ErrorText,
                        StrSubstNo(
                            'Tax Area Code %1 does not exist.',
                            Staging."Tax Area Code"));
            end;
        end;
    end;
    // LINE TYPE AND NO
    local procedure ValidateLineTypeAndNo(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Resource: Record Resource;
        FixedAsset: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
    begin
        // Type must contain a value
        if Staging.Type = Staging.Type::" " then begin
            AddError(ErrorText, 'Type must contain a value.');
            exit;
        end;

        // Comment lines do not require No.
        if Staging.Type = Staging.Type::Comment then
            exit;

        // No. must contain a value
        if Staging."No." = '' then begin
            AddError(ErrorText, 'No. must contain a value.');
            exit;
        end;

        // Validate based on Type
        case Staging.Type of

            // ==============================
            // G/L ACCOUNT
            // ==============================
            Staging.Type::"G/L Account":
                begin
                    if not GLAccount.Get(Staging."No.") then begin
                        AddError(ErrorText, 'G/L Account does not exist.');
                        exit;
                    end;

                    if GLAccount.Blocked then
                        AddError(ErrorText, 'G/L Account is blocked.');

                    if not GLAccount."Direct Posting" then
                        AddError(ErrorText, 'G/L Account does not allow direct posting.');

                    if GLAccount."Account Type" = GLAccount."Account Type"::Total then
                        AddError(ErrorText, 'G/L Account is a totaling account.');
                end;

            // ==============================
            // ITEM
            // ==============================
            Staging.Type::Item:
                begin
                    if not Item.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Item does not exist.');
                        exit;
                    end;

                    if Item.Blocked then
                        AddError(ErrorText, 'Item is blocked.');
                end;

            // ==============================
            // RESOURCE
            // ==============================
            Staging.Type::Resource:
                begin
                    if not Resource.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Resource does not exist.');
                        exit;
                    end;

                    if Resource.Blocked then
                        AddError(ErrorText, 'Resource is blocked.');
                end;

            // ==============================
            // FIXED ASSET
            // ==============================
            Staging.Type::"Fixed Asset":
                begin
                    if not FixedAsset.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Fixed Asset does not exist.');
                        exit;
                    end;

                    if FixedAsset.Blocked then
                        AddError(ErrorText, 'Fixed Asset is blocked.');
                end;
        end;
    end;
    // DESCRIPTION
    local procedure ValidateDescription(var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Resource: Record Resource;
        FixedAsset: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        NewDescription: Text[100];
    begin
        // If already filled, do nothing
        if Staging.Description <> '' then
            exit;

        case Staging.Type of

            Staging.Type::"G/L Account":
                if GLAccount.Get(Staging."No.") then
                    NewDescription := GLAccount.Name;

            Staging.Type::Item:
                if Item.Get(Staging."No.") then
                    NewDescription := Item.Description;

            Staging.Type::Resource:
                if Resource.Get(Staging."No.") then
                    NewDescription := Resource.Name;

            Staging.Type::"Fixed Asset":
                if FixedAsset.Get(Staging."No.") then
                    NewDescription := FixedAsset.Description;

            Staging.Type::"Charge (Item)":
                if ItemCharge.Get(Staging."No.") then
                    NewDescription := ItemCharge.Description;

            Staging.Type::Comment,
            Staging.Type::" ":
                exit; // no defaulting

        end;

        if NewDescription <> '' then begin
            Staging.Description := NewDescription;
            Staging.Modify();
        end;
    end;
    // LOCATION
    local procedure ValidateLocation(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        Location: Record Location;
    begin
        if Staging."Location Code" <> '' then
            if not Location.Get(Staging."Location Code") then
                AddError(ErrorText, 'Location Code does not exist.');
    end;

    // AMOUNTS
    local procedure ValidateAmounts(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        ExpectedAmount: Decimal;
        CalcDiscPct: Decimal;
        Tolerance: Decimal;
    begin
        Tolerance := 0.01;

        // ============================
        // Validate required fields
        // ============================
        if Staging.Quantity = 0 then
            AddError(ErrorText, 'Quantity must contain a value.');

        if Staging."Unit Cost/Price" = 0 then
            AddError(ErrorText, 'Unit Cost/Price must contain a value.');

        // If critical fields missing → cannot continue
        if (Staging.Quantity = 0) or (Staging."Unit Cost/Price" = 0) then
            exit;

        // ============================
        // If Line Amount not provided → calculate it
        // ============================
        if Staging."Line Amount" = 0 then begin
            Staging."Line Amount" :=
                Round(Staging.Quantity * Staging."Unit Cost/Price", 0.01);
            Staging.Modify();
            exit; // no discount needed—values consistent
        end;

        // ============================
        // Auto-discount calculation
        // ============================
        ExpectedAmount := Round(Staging.Quantity * Staging."Unit Cost/Price", 0.01);

        // If amounts match within tolerance → all good, no discount needed
        if Abs(ExpectedAmount - Staging."Line Amount") <= Tolerance then
            exit;

        // Calculate discount %
        CalcDiscPct :=
            100 - (Staging."Line Amount" / ExpectedAmount) * 100;

        // Validate discount range
        if (CalcDiscPct < 0) or (CalcDiscPct > 100) then begin
            AddError(
                ErrorText,
                StrSubstNo(
                    'Invalid discount calculated (%1%) for Entry %2. Qty=%3 UnitCost=%4 Amount=%5.',
                    CalcDiscPct,
                    Staging."Entry No.",
                    Staging.Quantity,
                    Staging."Unit Cost/Price",
                    Staging."Line Amount"
                )
            );
            exit;
        end;

        // Write discount back into staging table
        Staging."Line Discount %" := Round(CalcDiscPct, 0.0001);
        Staging.Modify();
    end;

    // UNIT OF MEASURE
    local procedure ValidateUnitOfMeasure(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        UOM: Record "Unit of Measure";
        IUOM: Record "Item Unit of Measure";
        RUOM: Record "Resource Unit of Measure";

    begin

        case Staging.Type of

            Staging.Type::Item:
                if Staging."Unit of Measure" = '' then
                    AddError(ErrorText, 'Unit of Measure for Items cannot be empty.')
                else begin
                    IUOM.Get(Staging."No.", Staging."Unit of Measure");
                    if IUOM.IsEmpty() then
                        AddError(ErrorText, 'Item Unit of Measure must exist.')
                end;

            Staging.Type::Resource:
                if Staging."Unit of Measure" = '' then
                    AddError(ErrorText, 'Unit of Measure for Resources cannot be empty.')
                else begin
                    RUOM.Get(Staging."No.", Staging."Unit of Measure");
                    if IUOM.IsEmpty() then
                        AddError(ErrorText, 'Resource Unit of Measure must exist.')
                end;

        end;

        if Staging."Unit of Measure" <> '' then
            if not UOM.Get(Staging."Unit of Measure") then
                AddError(ErrorText, 'Unit of Measure does not exist.');
    end;

    // TAX GROUP CODE
    local procedure ValidateTaxGroup(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    var
        TaxGroup: Record "Tax Group";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        ItemCharge: Record "Item Charge";
        DefaultTaxGroupCode: Code[20];
    begin
        // --------------------------------------------------
        // 1️⃣ If filled → must exist
        // --------------------------------------------------
        if Staging."Tax Group Code" <> '' then begin

            if not TaxGroup.Get(Staging."Tax Group Code") then
                AddError(ErrorText,
                    StrSubstNo(
                        'Tax Group Code %1 does not exist.',
                        Staging."Tax Group Code"));

        end else begin

            // --------------------------------------------------
            // If empty → try to default from No.
            // --------------------------------------------------
            case Staging.Type of

                Staging.Type::"G/L Account":
                    if GLAccount.Get(Staging."No.") then
                        DefaultTaxGroupCode := GLAccount."Tax Group Code";

                Staging.Type::Item:
                    if Item.Get(Staging."No.") then
                        DefaultTaxGroupCode := Item."Tax Group Code";

                Staging.Type::"Charge (Item)":
                    if ItemCharge.Get(Staging."No.") then
                        DefaultTaxGroupCode := ItemCharge."Tax Group Code";

            end;

            if DefaultTaxGroupCode <> '' then begin
                Staging."Tax Group Code" := DefaultTaxGroupCode;
                Staging.Modify();
            end;
        end;

        // --------------------------------------------------
        // If Tax Liable = TRUE → must have value
        // --------------------------------------------------
        if Staging."Tax Liable" and (Staging."Tax Group Code" = '') then
            AddError(ErrorText,
                'Tax Group Code must contain a value when Tax Liable is true.');
    end;

    // DIMENSIONS
    local procedure ValidateDimension(ShortcutNo: Integer; DimValueCode: Code[20]; var ErrorText: Text[1024])
    var
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;
        DimValue: Record "Dimension Value";
        DimCode: Code[20];
    begin
        if DimValueCode = '' then
            exit;

        GLSetup.Get();

        case ShortcutNo of
            1:
                DimCode := GLSetup."Shortcut Dimension 1 Code";
            2:
                DimCode := GLSetup."Shortcut Dimension 2 Code";
            3:
                DimCode := GLSetup."Shortcut Dimension 3 Code";
            4:
                DimCode := GLSetup."Shortcut Dimension 4 Code";
            5:
                DimCode := GLSetup."Shortcut Dimension 5 Code";
            6:
                DimCode := GLSetup."Shortcut Dimension 6 Code";
            7:
                DimCode := GLSetup."Shortcut Dimension 7 Code";
            8:
                DimCode := GLSetup."Shortcut Dimension 8 Code";
        end;

        if not DimValue.Get(DimCode, DimValueCode) then
            AddError(ErrorText,
                StrSubstNo(
                    'Dimension value %1 does not exist in dimension %2.',
                    DimValueCode, DimCode))
        else
            if DimValue.Blocked then
                AddError(ErrorText,
                    StrSubstNo(
                        'Dimension value %1 in dimension %2 is blocked.',
                        DimValueCode, DimCode));
    end;
    #ENDREGION VALIDATION PROCEDURES

    // ****************************************************
    #REGION HELPER
    // ****************************************************
    local procedure AddError(var ErrorText: Text[1024]; NewError: Text)
    begin
        if ErrorText = '' then
            ErrorText := NewError
        else
            ErrorText := ErrorText + ' | ' + NewError;
    end;

    local procedure OpenStagingValidationView(var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
    begin
        StagingPage.SetValidationView();
        StagingPage.SetTableView(Staging);
        StagingPage.Run();
    end;

    local procedure OpenStagingProcessingView(var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
    begin
        StagingPage.SetProcessingView();
        StagingPage.SetTableView(Staging);
        StagingPage.Run();
    end;

    // ****************************************************
    #ENDREGION HELPER
    // ****************************************************        
}