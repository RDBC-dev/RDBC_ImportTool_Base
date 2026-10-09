codeunit 85147 "RDBC_Base_TryCreation_PO"
{
    var
        GroupRec: Record "RDBC_Base_DocImp_Staging";
        PurchNo: Code[20];

    Trigger onrun()
    begin
        PurchNo := CreatePurchDocument(GroupRec);
        Clear(GroupRec);
    end;

    procedure SetGroupRec(var NewGroupRec: Record "RDBC_Base_DocImp_Staging")
    begin

        GroupRec := NewGroupRec;
        GroupRec.CopyFilters(NewGroupRec);
        // if not Confirm ('Old: %1\\New: %2', false, GroupRec.GetFilters(), NewGroupRec.GetFilters()) then
        //     Error('');   
    end;

    procedure GetPurchNo(): Code[20]
    begin
        exit(PurchNo);
    end;

    local procedure CreatePurchDocument(var GroupRec: Record "RDBC_Base_DocImp_Staging"): Code[20]
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
        FirstLine: Boolean;

        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        NewDimSetID: Integer;
        GLSetup: Record "General Ledger Setup";

    begin
        LineNo := 10000;
        FirstLine := true;

        if GroupRec.FindSet() then
            repeat

                // ===============================
                // CREATE HEADER ON FIRST LINE
                // ===============================
                if FirstLine then begin

                    PurchHeader.Init();
                    PurchHeader."Document Type" :=
                        PurchHeader."Document Type"::Order;
                    PurchHeader.Insert(true);

                    PurchHeader.Validate("Buy-from Vendor No.",
                        GroupRec."Business Relation No.");
                    PurchHeader.Validate("Posting Date",
                        GroupRec."Posting Date");
                    PurchHeader.Validate("Document Date",
                        GroupRec."Document Date");
                    PurchHeader.Validate("Vendor Invoice No.",
                        GroupRec."External Document No.");
                    PurchHeader.Validate("Tax Liable",
                        GroupRec."Tax Liable");
                    PurchHeader.Validate("Tax Area Code",
                        GroupRec."Tax Area Code");
                    PurchHeader."RDBC_Base_Data Import Name" :=
                        GroupRec."Data Import Name";
                    // PurchHeader."Posting Description" := GroupRec."Data Import Name";

                    PurchHeader.Modify(true);

                    FirstLine := false;
                end;

                // ===============================
                // CREATE LINE
                // ===============================

                PurchLine.Init();
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";
                PurchLine."Line No." := LineNo;
                PurchLine.Insert(true);

                LineNo += 10000;

                // Map custom enum to BC enum
                SetPurchaseLineType(PurchLine, GroupRec);

                // Validate No. if required
                if GroupRec.Type <> GroupRec.Type::Comment then
                    PurchLine.Validate("No.", GroupRec."No.");

                PurchLine.Validate(Description, GroupRec.Description);
                PurchLine.Validate("Location Code",
                    GroupRec."Location Code");
                PurchLine.Validate(Quantity,
                    GroupRec.Quantity);
                PurchLine.Validate("Unit of Measure Code",
                    GroupRec."Unit of Measure");
                PurchLine.Validate("Direct Unit Cost",
                    GroupRec."Unit Cost/Price");
                PurchLine.Validate("Line Discount %",
                    GroupRec."Line Discount %");
                PurchLine.Validate("Tax Group Code",
                    GroupRec."Tax Group Code");

                PurchLine."RDBC_Base_Data Import Name" := GroupRec."Data Import Name";
                PurchLine."RDBC_Base_Data Imp. Entry No." := GroupRec."Entry No.";

                // ===============================
                // DIMENSIONS (MERGE LOGIC)
                // ===============================

                if HasAnyShortcutDimension(GroupRec) then begin

                    TempDimSetEntry.DeleteAll();

                    // Load existing dimensions from line
                    DimMgt.GetDimensionSet(TempDimSetEntry, PurchLine."Dimension Set ID");

                    GLSetup.Get();

                    // Override only provided shortcut dimensions
                    UpdateShortcutDim(TempDimSetEntry,
                        GLSetup."Shortcut Dimension 1 Code",
                        GroupRec."Shortcut Dimension 1");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 2 Code",
                        GroupRec."Shortcut Dimension 2");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 3 Code",
                        GroupRec."Shortcut Dimension 3");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 4 Code",
                        GroupRec."Shortcut Dimension 4");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 5 Code",
                        GroupRec."Shortcut Dimension 5");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 6 Code",
                        GroupRec."Shortcut Dimension 6");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 7 Code",
                        GroupRec."Shortcut Dimension 7");

                    UpdateShortcutDim(
                        TempDimSetEntry,
                        GLSetup."Shortcut Dimension 8 Code",
                        GroupRec."Shortcut Dimension 8");

                    NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
                    // PurchLine."Dimension Set ID" := NewDimSetID;
                    PurchLine.Validate("Dimension Set ID", NewDimSetID);
                end;

                PurchLine.Modify(true);

            until GroupRec.Next() = 0;

        exit(PurchHeader."No.");
    end;


    // =====================================================
    // ENUM MAPPING
    // =====================================================

    local procedure SetPurchaseLineType(var PurchLine: Record "Purchase Line"; Staging: Record "RDBC_Base_DocImp_Staging")
    begin
        case Staging.Type of

            Staging.Type::"G/L Account":
                PurchLine.Validate(Type,
                    PurchLine.Type::"G/L Account");

            Staging.Type::Item:
                PurchLine.Validate(Type,
                    PurchLine.Type::Item);

            Staging.Type::Resource:
                PurchLine.Validate(Type,
                    PurchLine.Type::Resource);

            Staging.Type::"Fixed Asset":
                PurchLine.Validate(Type,
                    PurchLine.Type::"Fixed Asset");

            Staging.Type::"Charge (Item)":
                PurchLine.Validate(Type,
                    PurchLine.Type::"Charge (Item)");

            Staging.Type::Comment:
                PurchLine.Validate(Type,
                    PurchLine.Type::" ");

        end;
    end;

    local procedure HasAnyShortcutDimension(GroupRec: Record "RDBC_Base_DocImp_Staging"): Boolean
    begin
        exit(
            (GroupRec."Shortcut Dimension 1" <> '') or
            (GroupRec."Shortcut Dimension 2" <> '') or
            (GroupRec."Shortcut Dimension 3" <> '') or
            (GroupRec."Shortcut Dimension 4" <> '') or
            (GroupRec."Shortcut Dimension 5" <> '') or
            (GroupRec."Shortcut Dimension 6" <> '') or
            (GroupRec."Shortcut Dimension 7" <> '') or
            (GroupRec."Shortcut Dimension 8" <> '')
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
    // =====================================================
    // ERROR LOGGING
    // =====================================================

    local procedure LogProcessingError(var GroupRec: Record "RDBC_Base_DocImp_Staging"; ErrorMessage: Text)
    begin
        if GroupRec.FindSet() then
            repeat
                GroupRec."Last Processing Error" :=
                    CopyStr(ErrorMessage, 1, 1024);
                GroupRec.Modify();
            until GroupRec.Next() = 0;
    end;



}