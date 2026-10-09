codeunit 85131 "RDBC_Base_JnlImpValidationMgt"
{
    procedure ValidateUnvalidatedLines(DataImportName: Text[50]) ErrorCount: Integer
    var
        Staging: Record "RDBC_Base_JnlImp_Staging";
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

    local procedure ValidateSingleLine(var Staging: Record "RDBC_Base_JnlImp_Staging"): Boolean
    var
        ErrorText: Text[1024];
    begin
        ErrorText := '';

        case Staging."Journal Import Type" of

            Staging."Journal Import Type"::"General":
                ValidateGL(Staging, ErrorText);

            Staging."Journal Import Type"::"Sales Payment":
                ValidateSalesPayment(Staging, ErrorText);

            Staging."Journal Import Type"::"Purchase Payment":
                ValidatePurchasePayment(Staging, ErrorText);
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


    procedure ValidateAndHandleResult(var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        WorkRec: Record "RDBC_Base_JnlImp_Staging";
        ErrorCount: Integer;
    begin
        WorkRec.Copy(Staging);
        WorkRec."Data Import Name" := Staging."Data Import Name";
        ErrorCount := ValidateUnvalidatedLines(Staging."Data Import Name");

        HandleValidationResult(WorkRec, ErrorCount);
    end;

    local procedure HandleValidationResult(var Staging: Record "RDBC_Base_JnlImp_Staging"; ErrorCount: Integer)
    var
        FilteredRec: Record "RDBC_Base_JnlImp_Staging";
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

    // JOURNAL Type GENERAL JOURNAL
    local procedure ValidateGL(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateBatch(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateDescription(Staging);
        ValidateCurrency(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        // ValidateZeroBalanceGroup(Staging, ErrorText);

        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
        // ValidateAdditionalDimension('CUSTOMERGROUP', Staging."Additional Dimension 1 Value", ErrorText);
        // ValidateAdditionalDimension('VENDORGROUP', Staging."Additional Dimension 2 Value", ErrorText);
        // ValidateAdditionalDimension('PARENTCOMPANY', Staging."Additional Dimension 3 Value", ErrorText);
        ValidateBusinessUnit(Staging.BU, ErrorText);

    end;

    local procedure ValidateSalesPayment(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateBatch(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateCurrency(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidateSalesPaymentRules(Staging, ErrorText);
        ValidateDescription(Staging);

        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
        // ValidateAdditionalDimension('CUSTOMERGROUP', Staging."Additional Dimension 1 Value", ErrorText);
        // ValidateAdditionalDimension('VENDORGROUP', Staging."Additional Dimension 2 Value", ErrorText);
        // ValidateAdditionalDimension('PARENTCOMPANY', Staging."Additional Dimension 3 Value", ErrorText);
        ValidateBusinessUnit(Staging.BU, ErrorText);
    end;

    local procedure ValidatePurchasePayment(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    begin
        ValidateDataImportName(Staging, ErrorText);
        ValidateBatch(Staging, ErrorText);
        ValidateDates(Staging, ErrorText);
        ValidateLineTypeAndNo(Staging, ErrorText);
        ValidateCurrency(Staging, ErrorText);
        ValidateAmounts(Staging, ErrorText);
        ValidatePurchasePaymentRules(Staging, ErrorText);
        ValidateDescription(Staging);

        ValidateDimension(1, Staging."Shortcut Dimension 1", ErrorText);
        ValidateDimension(2, Staging."Shortcut Dimension 2", ErrorText);
        ValidateDimension(3, Staging."Shortcut Dimension 3", ErrorText);
        ValidateDimension(4, Staging."Shortcut Dimension 4", ErrorText);
        ValidateDimension(5, Staging."Shortcut Dimension 5", ErrorText);
        ValidateDimension(6, Staging."Shortcut Dimension 6", ErrorText);
        ValidateDimension(7, Staging."Shortcut Dimension 7", ErrorText);
        ValidateDimension(8, Staging."Shortcut Dimension 8", ErrorText);
        // ValidateAdditionalDimension('CUSTOMERGROUP', Staging."Additional Dimension 1 Value", ErrorText);
        // ValidateAdditionalDimension('VENDORGROUP', Staging."Additional Dimension 2 Value", ErrorText);
        // ValidateAdditionalDimension('PARENTCOMPANY', Staging."Additional Dimension 3 Value", ErrorText);
        ValidateBusinessUnit(Staging.BU, ErrorText);
    end;

    // ****************************************************
    #REGION VALIDATION PROCEDURES *************************
    // ****************************************************

    // DATA IMPORT NAME
    local procedure ValidateDataImportName(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    begin
        if Staging."Data Import Name" = '' then
            AddError(ErrorText, 'Data Import Name must contain a value.');
    end;

    // BATCH NAME
    local procedure ValidateBatch(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])

    var
        Batch: Record "Gen. Journal Batch";
        TemplateName: Code[10];

    begin
        TemplateName := GetTemplateName(Staging."Journal Import Type");

        if not Batch.Get(TemplateName, Staging."Journal Batch Name")
        then
            AddError(ErrorText, 'Journal Batch does not exist.');
        exit;
    end;

    local procedure GetTemplateName(JournalImportType: Enum "RDBC_Base_JnlImpType"): Code[10]
    begin
        case JournalImportType of
            JournalImportType::"General":
                exit('GENERAL');
            JournalImportType::"Sales Payment":
                exit('GENERAL');
            JournalImportType::"Purchase Payment":
                exit('GENERAL');
        end;

        exit('GENERAL');
    end;


    // POSTING AND DOCUMENT DATE
    local procedure ValidateDates(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])

    begin
        if Staging."Posting Date" = 0D then
            AddError(ErrorText, 'Posting Date must contain a value.');
    end;

    // LINE TYPE AND NO
    local procedure ValidateLineTypeAndNo(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    var
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;

    begin
        // TYPE must contain a value
        if Staging.Type = Staging.Type::" " then begin
            AddError(ErrorText, 'Type must contain a value.');
            exit;
        end;

        // BAL. ACCOUNT is optional for Bank Account lines and for lines applied
        // directly to a document (they are balanced by other lines in the same group).
        if IsBalAccountRequired(Staging) and (Staging."Bal. Account Type" = Staging.Type::" ") then begin
            AddError(ErrorText, 'Bal. Account Type must contain a value.');
            exit;
        end;

        // NO. must contain a value
        if Staging."No." = '' then begin
            AddError(ErrorText, 'No. must contain a value.');
            exit;
        end;

        // Validate No. based on Type
        case Staging.Type of

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

            Staging.Type::"Bank Account":
                begin
                    if not BankAccount.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Bank Account does not exist.');
                        exit;
                    end;

                    if BankAccount.Blocked then
                        AddError(ErrorText, 'Bank Account is blocked.');


                    if BankAccount."Currency Code" <> Staging."Currency Code" then
                        AddError(ErrorText, 'Currency Code in line does not match the bank accounts.');
                end;

            Staging.Type::"Fixed Asset":
                begin
                    if not FixedAsset.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Fixed Asset does not exist.');
                        exit;
                    end;

                    if FixedAsset.Blocked then
                        AddError(ErrorText, 'Fixed Asset is blocked.');
                end;

            Staging.Type::Customer:
                begin
                    if not Customer.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Customer does not exist.');
                        exit;
                    end;

                    if Customer.Blocked <> Customer.Blocked::" " then
                        AddError(ErrorText, 'Customer is blocked.');
                end;

            Staging.Type::Vendor:
                begin
                    if not Vendor.Get(Staging."No.") then begin
                        AddError(ErrorText, 'Vendor does not exist.');
                        exit;
                    end;

                    if Vendor.Blocked <> Vendor.Blocked::" " then
                        AddError(ErrorText, 'Vendor is blocked.');
                end;
        end;

        // Validate Bal. Account No. based on Type
        if Staging."Bal. Account No." <> '' then begin

            case Staging."Bal. Account Type" of

                Staging."Bal. Account Type"::"G/L Account":
                    begin
                        if not GLAccount.Get(Staging."Bal. Account No.") then begin
                            AddError(ErrorText, 'Bal. Account does not exist.');
                            exit;
                        end;

                        if GLAccount.Blocked then
                            AddError(ErrorText, 'Bal. Account is blocked.');

                        if not GLAccount."Direct Posting" then
                            AddError(ErrorText, 'Bal. Account does not allow direct posting.');

                        if GLAccount."Account Type" = GLAccount."Account Type"::Total then
                            AddError(ErrorText, 'Bal. Account is a totaling account.');
                    end;


                Staging."Bal. Account Type"::"Bank Account":
                    begin
                        if not BankAccount.Get(Staging."Bal. Account No.") then begin
                            AddError(ErrorText, 'Bank Account does not exist.');
                            exit;
                        end;

                        if BankAccount.Blocked then
                            AddError(ErrorText, 'Bank Account is blocked.');


                        if BankAccount."Currency Code" <> Staging."Currency Code" then
                            AddError(ErrorText, 'Currency Code in line does not match the bank accounts.');
                    end;

                Staging."Bal. Account Type"::"Fixed Asset":
                    begin
                        if not FixedAsset.Get(Staging."No.") then begin
                            AddError(ErrorText, 'Bal. Fixed Asset does not exist.');
                            exit;
                        end;

                        if FixedAsset.Blocked then
                            AddError(ErrorText, 'Bal. Fixed Asset is blocked.');
                    end;
            end;
        end;
    end;

    // Bal. Account is only mandatory when there is nothing else to balance the line against:
    // a Bank Account line is balanced by the other lines in the same document group, and a line
    // that applies directly to an open document is balanced by the payment's Bal. Account line (if any).
    local procedure IsBalAccountRequired(var Staging: Record "RDBC_Base_JnlImp_Staging"): Boolean
    begin
        if Staging.Type = Staging.Type::"Bank Account" then
            exit(false);

        if Staging."Applies-to Invoice No." <> '' then
            exit(false);

        exit(true);
    end;

    // DESCRIPTION
    local procedure ValidateDescription(var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        NewDescription: Text[100];
    begin
        // If already filled, do nothing
        if Staging.Description <> '' then
            exit;

        case Staging.Type of

            Staging.Type::"G/L Account":
                if GLAccount.Get(Staging."No.") then
                    NewDescription := GLAccount.Name;

            Staging.Type::"Bank Account":
                if (BankAccount.Get(Staging."No.")) then
                    NewDescription := BankAccount.Name;

            Staging.Type::"Fixed Asset":
                if FixedAsset.Get(Staging."No.") then
                    NewDescription := FixedAsset.Description;

            Staging.Type::Customer:
                if Customer.Get(Staging."No.") then
                    NewDescription := Customer.Name;

            Staging.Type::Vendor:
                if Vendor.Get(Staging."No.") then
                    NewDescription := Vendor.Name;

        end;

        if NewDescription <> '' then begin
            Staging.Description := NewDescription;
            Staging.Modify();
        end;
    end;

    // CURRENCY
    local procedure ValidateCurrency(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    var
        Currency: Record Currency;
    begin
        if Staging."Currency Code" <> '' then
            if not Currency.Get(Staging."Currency Code") then
                AddError(ErrorText, 'Currency Code does not exist.');
    end;

    // AMOUNTS
    local procedure ValidateAmounts(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    begin
        // At least one of Amount / Amount LCY must be provided
        if (Staging.Amount = 0) and (Staging."Amount LCY" = 0) then begin
            AddError(ErrorText, 'Either Amount or Amount LCY must contain a value.');
            exit;
        end;

        if Staging."Currency Code" = '' then begin
            // Without a currency, Amount and Amount LCY are the same value - fill in whichever is missing
            if Staging.Amount = 0 then begin
                Staging.Amount := Staging."Amount LCY";
                Staging.Modify();
            end else
                if Staging."Amount LCY" = 0 then begin
                    Staging."Amount LCY" := Staging.Amount;
                    Staging.Modify();
                end else
                    if Staging.Amount <> Staging."Amount LCY" then
                        AddError(ErrorText, 'Amount and Amount LCY must be equal when Currency is blank.');
        end else
            if (Staging.Amount <> 0) and (Staging."Amount LCY" <> 0) and (Staging.Amount = Staging."Amount LCY") then
                AddError(ErrorText, 'Amount and Amount LCY cannot be equal if a Currency is involved.');
    end;

    local procedure ValidateSalesPaymentRules(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        OriginalApplyToNo: Code[20];
    begin
        // A Bank Account line only funds/balances the other lines in the same document
        // group - it is not applied to an invoice itself, so no further checks apply.
        if Staging.Type = Staging.Type::"Bank Account" then
            exit;

        if Staging.Type <> Staging.Type::Customer then begin
            AddError(ErrorText, 'Sales Payment lines require Type = Customer or Bank Account.');
            exit;
        end;

        if Staging.Amount >= 0 then
            AddError(ErrorText, 'Sales Payment amount must be negative.');

        if Staging."Applies-to Invoice No." = '' then begin
            AddError(ErrorText, 'Applies-to Invoice No. must contain a value for Sales Payment lines.');
            exit;
        end;

        OriginalApplyToNo := Staging."Applies-to Invoice No.";

        case FindOpenSalesInvoiceLedgEntry(Staging, CustLedgEntry) of
            "RDBC_Base_ApplyToMatchResult"::None:
                begin
                    AddError(ErrorText, StrSubstNo('No open Posted Sales Invoice with No., External Document No. or Your Reference %1 was found for customer %2.', OriginalApplyToNo, Staging."No."));
                    exit;
                end;
            "RDBC_Base_ApplyToMatchResult"::Ambiguous:
                begin
                    AddError(ErrorText, StrSubstNo('External Document No./Your Reference %1 matches more than one open Sales Invoice for customer %2. Use the Document No. instead.', OriginalApplyToNo, Staging."No."));
                    exit;
                end;
        end;

        if Staging."Currency Code" <> CustLedgEntry."Currency Code" then
            AddError(ErrorText, StrSubstNo('Currency Code must match the open invoice %1.', Staging."Applies-to Invoice No."));

        CustLedgEntry.CalcFields("Remaining Amount");

        if Abs(Staging.Amount) > Abs(CustLedgEntry."Remaining Amount") then
            AddError(
                ErrorText,
                StrSubstNo(
                    'Payment amount %1 exceeds the remaining amount %2 of invoice %3.',
                    Abs(Staging.Amount),
                    Abs(CustLedgEntry."Remaining Amount"),
                    Staging."Applies-to Invoice No."));

        ValidatePaymentGroupBalance(Staging, Staging.Type::Customer, ErrorText);
    end;

    // Matches "Applies-to Invoice No." against the posted Sales Invoice's Document No. first,
    // and falls back to matching it against the Cust. Ledger Entry's External Document No. or Your Reference.
    // When resolved via the fallback fields, the staging line is updated to the real Document No.
    local procedure FindOpenSalesInvoiceLedgEntry(var Staging: Record "RDBC_Base_JnlImp_Staging"; var CustLedgEntry: Record "Cust. Ledger Entry"): Enum "RDBC_Base_ApplyToMatchResult"
    var
        TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        MatchCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Reset();
        CustLedgEntry.SetRange("Customer No.", Staging."No.");
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Document No.", Staging."Applies-to Invoice No.");
        CustLedgEntry.SetRange(Open, true);

        if CustLedgEntry.FindFirst() then
            exit("RDBC_Base_ApplyToMatchResult"::Match);

        MatchCustLedgEntry.Reset();
        MatchCustLedgEntry.SetRange("Customer No.", Staging."No.");
        MatchCustLedgEntry.SetRange("Document Type", MatchCustLedgEntry."Document Type"::Invoice);
        MatchCustLedgEntry.SetRange(Open, true);
        MatchCustLedgEntry.SetRange("External Document No.", Staging."Applies-to Invoice No.");
        if MatchCustLedgEntry.FindSet() then
            repeat
                if not TempCustLedgEntry.Get(MatchCustLedgEntry."Entry No.") then begin
                    TempCustLedgEntry := MatchCustLedgEntry;
                    TempCustLedgEntry.Insert();
                end;
            until MatchCustLedgEntry.Next() = 0;

        MatchCustLedgEntry.Reset();
        MatchCustLedgEntry.SetRange("Customer No.", Staging."No.");
        MatchCustLedgEntry.SetRange("Document Type", MatchCustLedgEntry."Document Type"::Invoice);
        MatchCustLedgEntry.SetRange(Open, true);
        MatchCustLedgEntry.SetRange("Your Reference", Staging."Applies-to Invoice No.");
        if MatchCustLedgEntry.FindSet() then
            repeat
                if not TempCustLedgEntry.Get(MatchCustLedgEntry."Entry No.") then begin
                    TempCustLedgEntry := MatchCustLedgEntry;
                    TempCustLedgEntry.Insert();
                end;
            until MatchCustLedgEntry.Next() = 0;

        case TempCustLedgEntry.Count() of
            0:
                exit("RDBC_Base_ApplyToMatchResult"::None);
            1:
                begin
                    TempCustLedgEntry.FindFirst();
                    CustLedgEntry.Get(TempCustLedgEntry."Entry No.");
                    if Staging."Applies-to Invoice No." <> CustLedgEntry."Document No." then begin
                        Staging."Applies-to Invoice No." := CustLedgEntry."Document No.";
                        Staging.Modify();
                    end;
                    exit("RDBC_Base_ApplyToMatchResult"::Match);
                end;
            else
                exit("RDBC_Base_ApplyToMatchResult"::Ambiguous);
        end;
    end;

    // The total of all Customer/Vendor payment lines sharing the same Document No. must not
    // exceed the funding Bank Account line's amount within that same document group.
    local procedure ValidatePaymentGroupBalance(var Staging: Record "RDBC_Base_JnlImp_Staging"; PaymentLineType: Enum "RDBC_Base_JnlImpLineType"; var ErrorText: Text[1024])
    var
        GroupLines: Record "RDBC_Base_JnlImp_Staging";
        BankTotal: Decimal;
        PaymentTotal: Decimal;
    begin
        // When the payment line has its own Bal. Account Type = Bank Account, the journal line
        // is created directly with that bank account as the balance account - there is no separate
        // Bank Account staging line to match against, so the group-balance check does not apply.
        if Staging."Bal. Account Type" = Staging.Type::"Bank Account" then
            exit;

        GroupLines.Reset();
        GroupLines.SetRange("Data Import Name", Staging."Data Import Name");
        GroupLines.SetRange("Journal Import Type", Staging."Journal Import Type");
        GroupLines.SetRange("Journal Batch Name", Staging."Journal Batch Name");
        GroupLines.SetRange("Document No.", Staging."Document No.");

        if GroupLines.FindSet() then
            repeat
                if GroupLines.Type = GroupLines.Type::"Bank Account" then
                    BankTotal += Abs(GroupLines.Amount)
                else
                    if GroupLines.Type = PaymentLineType then
                        PaymentTotal += Abs(GroupLines.Amount);
            until GroupLines.Next() = 0;

        if PaymentTotal > BankTotal then
            AddError(
                ErrorText,
                StrSubstNo(
                    'Total payment amount %1 for Document No. %2 exceeds the Bank Account line amount %3.',
                    PaymentTotal,
                    Staging."Document No.",
                    BankTotal));
    end;

    local procedure ValidatePurchasePaymentRules(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        OriginalApplyToNo: Code[20];
    begin
        // A Bank Account line only funds/balances the other lines in the same document
        // group - it is not applied to an invoice itself, so no further checks apply.
        if Staging.Type = Staging.Type::"Bank Account" then
            exit;

        if Staging.Type <> Staging.Type::Vendor then begin
            AddError(ErrorText, 'Purchase Payment lines require Type = Vendor or Bank Account.');
            exit;
        end;

        if Staging.Amount <= 0 then
            AddError(ErrorText, 'Purchase Payment amount must be positive.');

        if Staging."Applies-to Invoice No." = '' then begin
            AddError(ErrorText, 'Applies-to Invoice No. must contain a value for Purchase Payment lines.');
            exit;
        end;

        OriginalApplyToNo := Staging."Applies-to Invoice No.";

        case FindOpenPurchaseInvoiceLedgEntry(Staging, VendorLedgEntry) of
            "RDBC_Base_ApplyToMatchResult"::None:
                begin
                    AddError(ErrorText, StrSubstNo('No open Posted Purchase Invoice with No. or External Document No. %1 was found for vendor %2 (checked both Document No. and External Document No.).', OriginalApplyToNo, Staging."No."));
                    exit;
                end;
            "RDBC_Base_ApplyToMatchResult"::Ambiguous:
                begin
                    AddError(ErrorText, StrSubstNo('External Document No. %1 matches more than one open Purchase Invoice for vendor %2. Use the Document No. instead.', OriginalApplyToNo, Staging."No."));
                    exit;
                end;
        end;

        VendorLedgEntry.CalcFields("Remaining Amount");

        if Staging."Currency Code" <> VendorLedgEntry."Currency Code" then
            AddError(ErrorText, StrSubstNo('Currency Code must match the open invoice %1.', Staging."Applies-to Invoice No."));

        if Abs(Staging.Amount) > Abs(VendorLedgEntry."Remaining Amount") then
            AddError(
                ErrorText,
                StrSubstNo(
                    'Payment amount %1 exceeds the remaining amount %2 of invoice %3.',
                    Abs(Staging.Amount),
                    Abs(VendorLedgEntry."Remaining Amount"),
                    Staging."Applies-to Invoice No."));

        ValidatePaymentGroupBalance(Staging, Staging.Type::Vendor, ErrorText);
    end;

    // Matches "Applies-to Invoice No." against the posted Purchase Invoice's Document No. first,
    // and falls back to matching it against the Vendor Ledger Entry's External Document No.
    // When resolved via External Document No., the staging line is updated to the real Document No.
    local procedure FindOpenPurchaseInvoiceLedgEntry(var Staging: Record "RDBC_Base_JnlImp_Staging"; var VendorLedgEntry: Record "Vendor Ledger Entry"): Enum "RDBC_Base_ApplyToMatchResult"
    begin
        VendorLedgEntry.Reset();
        VendorLedgEntry.SetRange("Vendor No.", Staging."No.");
        VendorLedgEntry.SetRange("Document Type", VendorLedgEntry."Document Type"::Invoice);
        VendorLedgEntry.SetRange("Document No.", Staging."Applies-to Invoice No.");
        VendorLedgEntry.SetRange(Open, true);

        if VendorLedgEntry.FindFirst() then
            exit("RDBC_Base_ApplyToMatchResult"::Match);

        VendorLedgEntry.Reset();
        VendorLedgEntry.SetRange("Vendor No.", Staging."No.");
        VendorLedgEntry.SetRange("Document Type", VendorLedgEntry."Document Type"::Invoice);
        VendorLedgEntry.SetRange("External Document No.", Staging."Applies-to Invoice No.");
        VendorLedgEntry.SetRange(Open, true);

        case VendorLedgEntry.Count() of
            0:
                exit("RDBC_Base_ApplyToMatchResult"::None);
            1:
                begin
                    VendorLedgEntry.FindFirst();
                    if Staging."Applies-to Invoice No." <> VendorLedgEntry."Document No." then begin
                        Staging."Applies-to Invoice No." := VendorLedgEntry."Document No.";
                        Staging.Modify();
                    end;
                    exit("RDBC_Base_ApplyToMatchResult"::Match);
                end;
            else
                exit("RDBC_Base_ApplyToMatchResult"::Ambiguous);
        end;
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

    local procedure ValidateAdditionalDimension(DimCode: Code[20]; DimValueCode: Code[20]; var ErrorText: Text[1024])
    var
        Dim: Record Dimension;
        DimValue: Record "Dimension Value";
    begin
        if DimValueCode = '' then
            exit;

        if not Dim.Get(DimCode) then begin
            AddError(
                ErrorText,
                StrSubstNo('Dimension %1 does not exist.', DimCode));
            exit;
        end;

        if not DimValue.Get(DimCode, DimValueCode) then begin
            AddError(
                ErrorText,
                StrSubstNo('Dimension value %1 does not exist in dimension %2.', DimValueCode, DimCode));
            exit;
        end;

        if DimValue.Blocked then
            AddError(
                ErrorText,
                StrSubstNo('Dimension value %1 in dimension %2 is blocked.', DimValueCode, DimCode));
    end;

    local procedure ValidateBusinessUnit(BusinessUnitCode: Code[20]; var ErrorText: Text[1024])
    var
        BusinessUnit: Record "Business Unit";
    begin
        if BusinessUnitCode = '' then
            exit;

        if not BusinessUnit.Get(BusinessUnitCode) then
            AddError(
                ErrorText,
                StrSubstNo('Business Unit %1 does not exist.', BusinessUnitCode));
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

    local procedure OpenStagingValidationView(var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        StagingPage: Page "RDBC_Base_JnlImp_Staging";
    begin
        StagingPage.SetValidationView();
        StagingPage.SetTableView(Staging);
        StagingPage.Run();
    end;

    local procedure OpenStagingProcessingView(var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        StagingPage: Page "RDBC_Base_JnlImp_Staging";
    begin
        StagingPage.SetProcessingView();
        StagingPage.SetTableView(Staging);
        StagingPage.Run();
    end;


    // ****************************************************
    #ENDREGION HELPER
    // ****************************************************        
}