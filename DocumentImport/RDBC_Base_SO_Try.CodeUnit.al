codeunit 85148 "RDBC_Base_TryCreation_SO"
{
    var
        GroupRec: Record "RDBC_Base_DocImp_Staging";
        SalesNo: Code[20];

    Trigger onrun()
    begin
        SalesNo := CreateSalesDocument(GroupRec);
        Clear(GroupRec);
    end;

    procedure SetGroupRec(var NewGroupRec: Record "RDBC_Base_DocImp_Staging")
    begin

        GroupRec := NewGroupRec;
        GroupRec.CopyFilters(NewGroupRec);
        // if not Confirm ('Old: %1\\New: %2', false, GroupRec.GetFilters(), NewGroupRec.GetFilters()) then
        //     Error('');   
    end;

    procedure GetSalesNo(): Code[20]
    begin
        exit(SalesNo);
    end;

    local procedure CreateSalesDocument(var GroupRec: Record "RDBC_Base_DocImp_Staging"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
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

                    SalesHeader.Init();
                    SalesHeader."Document Type" :=
                        SalesHeader."Document Type"::Order;
                    SalesHeader.Insert(true);

                    SalesHeader.Validate("Sell-to Customer No.",
                        GroupRec."Business Relation No.");
                    SalesHeader.Validate("Posting Date",
                        GroupRec."Posting Date");
                    SalesHeader.Validate("Document Date",
                        GroupRec."Document Date");
                    SalesHeader.Validate("External Document No.",
                        GroupRec."External Document No.");
                    SalesHeader.Validate("Your Reference",
                        GroupRec."External Document No.");
                    SalesHeader.Validate("Tax Liable",
                        GroupRec."Tax Liable");
                    SalesHeader.Validate("Tax Area Code",
                        GroupRec."Tax Area Code");
                    SalesHeader."RDBC_Base_Data Import Name" :=
                        GroupRec."Data Import Name";
                    //SalesHeader."Posting Description" := GroupRec."Data Import Name";

                    SalesHeader.Modify(true);

                    FirstLine := false;
                end;

                // ===============================
                // CREATE LINE
                // ===============================

                SalesLine.Init();
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Insert(true);

                LineNo += 10000;

                // Map custom enum to BC enum
                SetSalesLineType(SalesLine, GroupRec);

                // Validate No. if required
                if GroupRec.Type <> GroupRec.Type::Comment then
                    SalesLine.Validate("No.", GroupRec."No.");

                SalesLine.Validate(Description, GroupRec.Description);
                SalesLine.Validate("Location Code",
                    GroupRec."Location Code");
                SalesLine.Validate(Quantity,
                    GroupRec.Quantity);
                SalesLine.Validate("Unit of Measure Code",
                    GroupRec."Unit of Measure");
                SalesLine.Validate("Unit Price",
                    GroupRec."Unit Cost/Price");
                SalesLine.Validate("Line Discount %",
                    GroupRec."Line Discount %");
                SalesLine.Validate("Tax Group Code",
                    GroupRec."Tax Group Code");

                SalesLine."RDBC_Base_Data Import Name" := GroupRec."Data Import Name";
                SalesLine."RDBC_Base_Data Imp. Entry No." := GroupRec."Entry No.";

                // ===============================
                // DIMENSIONS (MERGE LOGIC)
                // ===============================

                if HasAnyShortcutDimension(GroupRec) then begin

                    TempDimSetEntry.DeleteAll();

                    // Load existing dimensions from line
                    DimMgt.GetDimensionSet(TempDimSetEntry, SalesLine."Dimension Set ID");

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
                    //SalesLine."Dimension Set ID" := NewDimSetID;
                    SalesLine.Validate("Dimension Set ID", NewDimSetID);
                end;

                SalesLine.Modify(true);

            until GroupRec.Next() = 0;

        exit(SalesHeader."No.");
    end;


    // =====================================================
    // ENUM MAPPING
    // =====================================================

    local procedure SetSalesLineType(var SalesLine: Record "Sales Line"; Staging: Record "RDBC_Base_DocImp_Staging")
    begin
        case Staging.Type of

            Staging.Type::"G/L Account":
                SalesLine.Validate(Type,
                    SalesLine.Type::"G/L Account");

            Staging.Type::Item:
                SalesLine.Validate(Type,
                    SalesLine.Type::Item);

            Staging.Type::Resource:
                SalesLine.Validate(Type,
                    SalesLine.Type::Resource);

            Staging.Type::"Fixed Asset":
                SalesLine.Validate(Type,
                    SalesLine.Type::"Fixed Asset");

            Staging.Type::"Charge (Item)":
                SalesLine.Validate(Type,
                    SalesLine.Type::"Charge (Item)");

            Staging.Type::Comment:
                SalesLine.Validate(Type,
                    SalesLine.Type::" ");

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