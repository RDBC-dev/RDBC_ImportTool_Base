codeunit 85151 "RDBC_Base_TryCreationGenJnl"
{
    var
        GroupRec: Record "RDBC_Base_JnlImp_Staging";
        DocNo: Code[20];

    Trigger onrun()
    begin
        DocNo := CreateGeneralJournal(GroupRec);
        Clear(GroupRec);
    end;

    procedure SetGroupRec(var NewGroupRec: Record "RDBC_Base_JnlImp_Staging")
    begin

        GroupRec := NewGroupRec;
        GroupRec.CopyFilters(NewGroupRec);
    end;

    procedure GetDocNo(): Code[20]
    begin
        exit(DocNo);
    end;

    local procedure CreateGeneralJournal(var GroupRec: Record "RDBC_Base_JnlImp_Staging"): Code[20]
    var
        GenJnl: Record "Gen. Journal Line";
        LineNo: Integer;

        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        NewDimSetID: Integer;
        GLSetup: Record "General Ledger Setup";

        GenJnlTemplateName: Code[10];
        GenJnlBatchName: Code[10];
        DocumentNo: Code[20];

    begin
        GenJnlTemplateName := GetTemplateName(GroupRec."Journal Import Type");
        GenJnlBatchName := GroupRec."Journal Batch Name";

        GLSetup.Get();

        GenJnl.Reset();
        GenJnl.SetRange("Journal Template Name", GenJnlTemplateName);
        GenJnl.SetRange("Journal Batch Name", GenJnlBatchName);

        if GenJnl.FindLast() then
            LineNo := GenJnl."Line No." + 10000
        else
            LineNo := 10000;

        if GroupRec.FindSet() then begin

            DocumentNo := GroupRec."Document No.";

            repeat
                // =================================
                // CREATE GENERAL JOURNAL LINE
                // =================================
                GenJnl.Init();
                GenJnl."Journal Template Name" := GenJnlTemplateName;
                GenJnl."Journal Batch Name" := GenJnlBatchName;
                GenJnl."Line No." := LineNo;

                GenJnl.Validate("Posting Date", GroupRec."Posting Date");
                GenJnl.Validate("Document No.", GroupRec."Document No.");
                GenJnl.Validate("External Document No.", GroupRec."Document No.");

                if GroupRec."Journal Import Type" in
                   [GroupRec."Journal Import Type"::"Sales Payment", GroupRec."Journal Import Type"::"Purchase Payment"]
                then
                    GenJnl.Validate("Document Type", GenJnl."Document Type"::Payment);
                // Account Type
                SetJnlLineType(GenJnl, GroupRec);
                GenJnl.Validate("Account No.", GroupRec."No.");

                // ---------- AMOUNTS ----------
                GenJnl.Validate("Currency Code", GroupRec."Currency Code");
                GenJnl.Validate(Amount, GroupRec.Amount);
                if GroupRec."Amount LCY" <> 0 then begin
                    GenJnl.Validate("Amount (LCY)", GroupRec."Amount LCY");
                end;

                if GroupRec.BU <> '' then
                    GenJnl.Validate("Business Unit Code", GroupRec.BU);

                // Bal. Account Type
                SetJnlLineBalType(GenJnl, GroupRec);
                GenJnl.Validate("Bal. Account No.", GroupRec."Bal. Account No.");

                // Bank Account lines (used to fund/balance the group) have no Applies-to document
                if GroupRec."Applies-to Invoice No." <> '' then begin
                    GenJnl.Validate("Applies-to Doc. Type", GenJnl."Applies-to Doc. Type"::Invoice);
                    GenJnl.Validate("Applies-to Doc. No.", GroupRec."Applies-to Invoice No.");
                end;
                // Description
                GenJnl.Validate(Description, GroupRec.Description);
                GenJnl.Validate(Comment, GroupRec.Comment);

                // Save import metadata
                GenJnl."RDBC_Base_Data Import Name" := GroupRec."Data Import Name";
                GenJnl."RDBC_Base_Data Imp. Entry No." := GroupRec."Entry No.";

                // ========== DIMENSION LOGIC ==========

                if HasAnyImportedDimension(GroupRec) then begin
                    // TempDimSetEntry.DeleteAll();

                    DimMgt.GetDimensionSet(TempDimSetEntry, GenJnl."Dimension Set ID");

                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 1 Code", GroupRec."Shortcut Dimension 1");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 2 Code", GroupRec."Shortcut Dimension 2");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 3 Code", GroupRec."Shortcut Dimension 3");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 4 Code", GroupRec."Shortcut Dimension 4");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 5 Code", GroupRec."Shortcut Dimension 5");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 6 Code", GroupRec."Shortcut Dimension 6");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 7 Code", GroupRec."Shortcut Dimension 7");
                    UpdateShortcutDim(TempDimSetEntry, GLSetup."Shortcut Dimension 8 Code", GroupRec."Shortcut Dimension 8");
                    UpdateAdditionalDim(TempDimSetEntry, 'CUSTOMERGROUP', GroupRec."Additional Dimension 1 Value");
                    UpdateAdditionalDim(TempDimSetEntry, 'VENDORGROUP', GroupRec."Additional Dimension 2 Value");
                    UpdateAdditionalDim(TempDimSetEntry, 'PARENTCOMPANY', GroupRec."Additional Dimension 3 Value");

                    NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);

                    if GenJnl."Dimension Set ID" <> NewDimSetID then begin
                        GenJnl."Dimension Set ID" := NewDimSetID;

                        DimMgt.UpdateGlobalDimFromDimSetID(
                                 GenJnl."Dimension Set ID",
                                 GenJnl."Shortcut Dimension 1 Code",
                                 GenJnl."Shortcut Dimension 2 Code");
                    end;
                end;

                GenJnl.Insert(true);

                LineNo := LineNo + 10000;

            until GroupRec.Next() = 0;
        end;
        exit(DocumentNo);
    end;

    local procedure HasAnyImportedDimension(GroupRec: Record "RDBC_Base_JnlImp_Staging"): Boolean
    begin
        exit(
            (GroupRec."Shortcut Dimension 1" <> '') or
            (GroupRec."Shortcut Dimension 2" <> '') or
            (GroupRec."Shortcut Dimension 3" <> '') or
            (GroupRec."Shortcut Dimension 4" <> '') or
            (GroupRec."Shortcut Dimension 5" <> '') or
            (GroupRec."Shortcut Dimension 6" <> '') or
            (GroupRec."Shortcut Dimension 7" <> '') or
            (GroupRec."Shortcut Dimension 8" <> '') or
            (GroupRec."Additional Dimension 1 Value" <> '') or
            (GroupRec."Additional Dimension 2 Value" <> '') or
            (GroupRec."Additional Dimension 3 Value" <> '') or
            (GroupRec.BU <> '')
        );
    end;

    local procedure UpdateShortcutDim(var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    var
        DimValue: Record "Dimension Value";
    begin
        if (DimCode = '') or (DimValueCode = '') then
            exit;

        if not DimValue.Get(DimCode, DimValueCode) then
            Error(
                'Dimension value %1 does not exist in dimension %2.',
                DimValueCode,
                DimCode);

        // Remove existing dimension for this DimCode
        TempDimSetEntry.SetRange("Dimension Code", DimCode);
        TempDimSetEntry.DeleteAll();
        TempDimSetEntry.SetRange("Dimension Code");

        // Insert new one
        TempDimSetEntry.Init();
        TempDimSetEntry."Dimension Code" := DimCode;
        TempDimSetEntry."Dimension Value Code" := DimValueCode;
        TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
        TempDimSetEntry.Insert();
    end;

    local procedure UpdateAdditionalDim(var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        UpdateShortcutDim(TempDimSetEntry, DimCode, DimValueCode);
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
    // =====================================================
    // ERROR LOGGING
    // =====================================================

    local procedure SetJnlLineType(var GenJnl: Record "Gen. Journal Line"; Staging: Record "RDBC_Base_JnlImp_Staging")
    begin
        case Staging.Type of

            Staging.Type::"G/L Account":
                GenJnl.Validate("Account Type",
                    GenJnl."Account Type"::"G/L Account");

            Staging.Type::"Fixed Asset":
                GenJnl.Validate("Account Type",
                    GenJnl."Account Type"::"Fixed Asset");

            Staging.Type::"Bank Account":
                GenJnl.Validate("Account Type",
                    GenJnl."Account Type"::"Bank Account");

            Staging.Type::Customer:
                GenJnl.Validate("Account Type",
                    GenJnl."Account Type"::Customer);

            Staging.Type::Vendor:
                GenJnl.Validate("Account Type",
                    GenJnl."Account Type"::Vendor);

        end;
    end;

    local procedure SetJnlLineBalType(var GenJnl: Record "Gen. Journal Line"; Staging: Record "RDBC_Base_JnlImp_Staging")
    begin
        case Staging."Bal. Account Type" of

            Staging."Bal. Account Type"::"G/L Account":
                GenJnl.Validate("Bal. Account Type",
                    GenJnl."Bal. Account Type"::"G/L Account");

            Staging."Bal. Account Type"::"Fixed Asset":
                GenJnl.Validate("Bal. Account Type",
                    GenJnl."Bal. Account Type"::"Fixed Asset");

            Staging."Bal. Account Type"::"Bank Account":
                GenJnl.Validate("Bal. Account Type",
                    GenJnl."Bal. Account Type"::"Bank Account");

        end;
    end;

    local procedure LogProcessingError(var GroupRec: Record "RDBC_Base_JnlImp_Staging"; ErrorMessage: Text)
    begin
        if GroupRec.FindSet() then
            repeat
                GroupRec."Last Processing Error" :=
                    CopyStr(ErrorMessage, 1, 1024);
                GroupRec.Modify();
            until GroupRec.Next() = 0;
    end;
}