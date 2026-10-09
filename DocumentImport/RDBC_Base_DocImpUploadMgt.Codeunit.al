codeunit 85120 "RDBC_Base_DocImpExcelMgt"
{
    procedure ImportExcelToStaging(InStr: InStream; DataImportName: Text[50])
    var
        Features: Codeunit "RDBC_Base_Features";
        ExcelBuffer: Record "Excel Buffer" temporary;
        Staging: Record "RDBC_Base_DocImp_Staging";
        CurrentRow: Integer;

        ValidationMgt: Codeunit "RDBC_Base_DocImpValidationMgt";
        ErrorCount: Integer;

        LineAmountText: Text;
        EvalOk: Boolean;

    begin
        Features.CheckDocumentUploadAllowed();
        if DataImportName = '' then
            Error('Data Import Name must be filled.');

        // Ensure Data Import Name is unique
        Staging.Reset();
        Staging.SetRange("Data Import Name", DataImportName);

        if not Staging.IsEmpty() then
            Error(
                'Data Import Name %1 already exists. Please choose a different name.',
                DataImportName);

        // Open workbook and explicitly open sheet "IMPORT"
        ExcelBuffer.OpenBookStream(InStr, 'IMPORT');
        ExcelBuffer.ReadSheet();

        // Skip header row (row 1)
        CurrentRow := 2;

        while ExcelBuffer.Get(CurrentRow, 1) do begin

            Staging.Init();
            ValidateExcelDateColumnsAreText(ExcelBuffer, CurrentRow);

            Evaluate(Staging."Document Import Type", GetCellValue(ExcelBuffer, CurrentRow, 1));
            Staging."Posting Date" := GetCellDateValue(ExcelBuffer, CurrentRow, 2);
            Staging."Document Date" := GetCellDateValue(ExcelBuffer, CurrentRow, 3);
            Evaluate(Staging."Business Relation Type", GetCellValue(ExcelBuffer, CurrentRow, 4));
            Staging."Business Relation No." := GetCellValue(ExcelBuffer, CurrentRow, 5);
            Staging."External Document No." := GetCellValue(ExcelBuffer, CurrentRow, 6);
            Evaluate(Staging."Tax Liable", GetCellValue(ExcelBuffer, CurrentRow, 7));
            Staging."Tax Area Code" := GetCellValue(ExcelBuffer, CurrentRow, 8);
            Evaluate(Staging.Type, GetCellValue(ExcelBuffer, CurrentRow, 9));
            Staging."No." := GetCellValue(ExcelBuffer, CurrentRow, 10);
            Staging.Description := GetCellValue(ExcelBuffer, CurrentRow, 11);
            Staging."Location Code" := GetCellValue(ExcelBuffer, CurrentRow, 12);
            Evaluate(Staging.Quantity, GetCellValue(ExcelBuffer, CurrentRow, 13));
            Staging."Unit of Measure" := GetCellValue(ExcelBuffer, CurrentRow, 14);
            Evaluate(Staging."Unit Cost/Price", GetCellValue(ExcelBuffer, CurrentRow, 15));
            LineAmountText := GetCellValue(ExcelBuffer, CurrentRow, 16);

            if LineAmountText = '' then
                Staging."Line Amount" :=
                Round(Staging.Quantity * Staging."Unit Cost/Price", 0.01)
            else
                Evaluate(Staging."Line Amount", LineAmountText);

            Staging."Tax Group Code" := GetCellValue(ExcelBuffer, CurrentRow, 17);
            Staging."Shortcut Dimension 1" := GetCellValue(ExcelBuffer, CurrentRow, 18);
            Staging."Shortcut Dimension 2" := GetCellValue(ExcelBuffer, CurrentRow, 19);
            Staging."Shortcut Dimension 3" := GetCellValue(ExcelBuffer, CurrentRow, 20);
            Staging."Shortcut Dimension 4" := GetCellValue(ExcelBuffer, CurrentRow, 21);
            Staging."Shortcut Dimension 5" := GetCellValue(ExcelBuffer, CurrentRow, 22);
            Staging."Shortcut Dimension 6" := GetCellValue(ExcelBuffer, CurrentRow, 23);
            Staging."Shortcut Dimension 7" := GetCellValue(ExcelBuffer, CurrentRow, 24);
            Staging."Shortcut Dimension 8" := GetCellValue(ExcelBuffer, CurrentRow, 25);
            Staging."Apply to Document" := GetCellValue(ExcelBuffer, CurrentRow, 26);
            Staging."Data Import Name" := DataImportName;
            Staging."Entry No." := 0; // Auto-increment field, will be set on insert
            Staging.Insert(true);

            CurrentRow += 1;
        end;

        FinalizeImport(DataImportName);
    end;


    procedure ImportCsvToStaging(InStr: InStream; DataImportName: Text[50])
    var
        Features: Codeunit "RDBC_Base_Features";
        Staging: Record "RDBC_Base_DocImp_Staging";
        LineText: Text;
        Columns: List of [Text];
        Delimiter: Text[1];
        LineAmountText: Text;
        IsFirstLine: Boolean;
        EvalOk: Boolean;
    begin
        Features.CheckDocumentCsvUploadAllowed();
        if DataImportName = '' then
            Error('Data Import Name must be filled.');

        // Ensure Data Import Name is unique
        Staging.Reset();
        Staging.SetRange("Data Import Name", DataImportName);

        if not Staging.IsEmpty() then
            Error(
                'Data Import Name %1 already exists. Please choose a different name.',
                DataImportName);

        IsFirstLine := true;

        while not InStr.EOS() do begin
            InStr.ReadText(LineText);

            if IsFirstLine then begin
                // Header row is used only to detect the delimiter, then skipped
                Delimiter := DetectCsvDelimiter(LineText);
                IsFirstLine := false;
            end else
                if LineText.Trim() <> '' then begin
                    Columns := SplitCsvLine(LineText, Delimiter);

                    Staging.Init();

                    // Evaluate's return value is captured (not checked) so a blank/unparseable
                    // column is simply left at the field's default instead of throwing. No
                    // validity checking happens here - that belongs to the validation codeunit.
                    Evaluate(Staging."Document Import Type", GetColumnValue(Columns, 1));
                    Staging."Posting Date" := GetColumnDateValue(Columns, 2);
                    Staging."Document Date" := GetColumnDateValue(Columns, 3);
                    Evaluate(Staging."Business Relation Type", GetColumnValue(Columns, 4));
                    Staging."Business Relation No." := CopyStr(GetColumnValue(Columns, 5), 1, MaxStrLen(Staging."Business Relation No."));
                    Staging."External Document No." := CopyStr(GetColumnValue(Columns, 6), 1, MaxStrLen(Staging."External Document No."));
                    // Column 7 (Tax Liable): blank leaves the field at its default (False, from
                    // Staging.Init()); a provided TRUE/FALSE value is evaluated directly.
                    EvalOk := Evaluate(Staging."Tax Liable", GetColumnValue(Columns, 7));
                    Staging."Tax Area Code" := CopyStr(GetColumnValue(Columns, 8), 1, MaxStrLen(Staging."Tax Area Code"));
                    Evaluate(Staging.Type, GetColumnValue(Columns, 9));
                    Staging."No." := CopyStr(GetColumnValue(Columns, 10), 1, MaxStrLen(Staging."No."));
                    Staging.Description := CopyStr(GetColumnValue(Columns, 11), 1, MaxStrLen(Staging.Description));
                    Staging."Location Code" := CopyStr(GetColumnValue(Columns, 12), 1, MaxStrLen(Staging."Location Code"));
                    Evaluate(Staging.Quantity, GetColumnValue(Columns, 13));
                    Staging."Unit of Measure" := CopyStr(GetColumnValue(Columns, 14), 1, MaxStrLen(Staging."Unit of Measure"));
                    Evaluate(Staging."Unit Cost/Price", GetColumnValue(Columns, 15));
                    LineAmountText := GetColumnValue(Columns, 16);

                    if LineAmountText = '' then
                        Staging."Line Amount" :=
                        Round(Staging.Quantity * Staging."Unit Cost/Price", 0.01)
                    else
                        Evaluate(Staging."Line Amount", LineAmountText);

                    Staging."Tax Group Code" := CopyStr(GetColumnValue(Columns, 17), 1, MaxStrLen(Staging."Tax Group Code"));
                    Staging."Shortcut Dimension 1" := CopyStr(GetColumnValue(Columns, 18), 1, MaxStrLen(Staging."Shortcut Dimension 1"));
                    Staging."Shortcut Dimension 2" := CopyStr(GetColumnValue(Columns, 19), 1, MaxStrLen(Staging."Shortcut Dimension 2"));
                    Staging."Shortcut Dimension 3" := CopyStr(GetColumnValue(Columns, 20), 1, MaxStrLen(Staging."Shortcut Dimension 3"));
                    Staging."Shortcut Dimension 4" := CopyStr(GetColumnValue(Columns, 21), 1, MaxStrLen(Staging."Shortcut Dimension 4"));
                    Staging."Shortcut Dimension 5" := CopyStr(GetColumnValue(Columns, 22), 1, MaxStrLen(Staging."Shortcut Dimension 5"));
                    Staging."Shortcut Dimension 6" := CopyStr(GetColumnValue(Columns, 23), 1, MaxStrLen(Staging."Shortcut Dimension 6"));
                    Staging."Shortcut Dimension 7" := CopyStr(GetColumnValue(Columns, 24), 1, MaxStrLen(Staging."Shortcut Dimension 7"));
                    Staging."Shortcut Dimension 8" := CopyStr(GetColumnValue(Columns, 25), 1, MaxStrLen(Staging."Shortcut Dimension 8"));
                    Staging."Apply to Document" := CopyStr(GetColumnValue(Columns, 26), 1, MaxStrLen(Staging."Apply to Document"));
                    Staging."Data Import Name" := DataImportName;
                    Staging."Entry No." := 0; // Auto-increment field, will be set on insert
                    Staging.Insert(true);
                end;
        end;

        FinalizeImport(DataImportName);
    end;

    local procedure FinalizeImport(DataImportName: Text[50])
    var
        Staging: Record "RDBC_Base_DocImp_Staging";
        ValidationMgt: Codeunit "RDBC_Base_DocImpValidationMgt";
        ErrorCount: Integer;
    begin
        // Starts validation of all lines after import, can be removed if validation should be manual from staging page
        ErrorCount := ValidationMgt.ValidateUnvalidatedLines(DataImportName);

        if ErrorCount > 0 then begin
            if Confirm(
                StrSubstNo(
                    '%1 line(s) contain validation errors.\Do you want to review the errors now?',
                    ErrorCount),
                false,
                'Go to errors',
                'Close')
            then begin
                Staging.Reset();
                Staging.SetRange("Data Import Name", DataImportName);
                Staging.SetRange(Validated, false);

                OpenStagingValidationView(Staging);
            end;
        end else begin
            if Confirm(
                'All lines were validated successfully.\Do you want to open the imported lines?',
                false,
                'Open staging',
                'Close')
            then begin
                Staging.Reset();
                Staging.SetRange("Data Import Name", DataImportName);

                OpenStagingProcessingView(Staging);
            end;
        end;
    end;

    local procedure GetCellValue(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColumnNo) then
            exit(ExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure ValidateExcelDateColumnsAreText(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer)
    begin
        if ExcelBuffer.Get(RowNo, 2) and (ExcelBuffer."Cell Type" <> ExcelBuffer."Cell Type"::Text) then
            Error('Posting Date in Excel must be formatted as Text, not %1.', Format(ExcelBuffer."Cell Type"));

        if ExcelBuffer.Get(RowNo, 3) and (ExcelBuffer."Cell Type" <> ExcelBuffer."Cell Type"::Text) then
            Error('Document Date in Excel must be formatted as Text, not %1.', Format(ExcelBuffer."Cell Type"));
    end;

    local procedure GetCellDateValue(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer): Date
    begin
        if not ExcelBuffer.Get(RowNo, ColumnNo) then
            exit(0D);

        exit(ParseDateText(ExcelBuffer."Cell Value as Text"));
    end;

    local procedure ParseDateText(RawText: Text): Date
    var
        RawDate: Date;
        RawDateTime: DateTime;
        SerialNumber: Integer;
        BaseDate: Date;
        DatePartText: Text;
        SpacePos: Integer;
        TPos: Integer;
    begin
        if RawText = '' then
            exit(0D);

        // Direct date string
        if Evaluate(RawDate, RawText) then
            exit(RawDate);

        // If there is a time portion, parse only the date part to avoid timezone shift
        SpacePos := StrPos(RawText, ' ');
        if SpacePos > 0 then begin
            DatePartText := CopyStr(RawText, 1, SpacePos - 1);
            if Evaluate(RawDate, DatePartText) then
                exit(RawDate);
        end;

        TPos := StrPos(RawText, 'T');
        if TPos > 0 then begin
            DatePartText := CopyStr(RawText, 1, TPos - 1);
            if Evaluate(RawDate, DatePartText) then
                exit(RawDate);
        end;

        // Fallback for raw DateTime if text includes timezone-adjusted datetime
        if Evaluate(RawDateTime, RawText) then
            exit(DT2DATE(RawDateTime));

        // Excel serial number text
        if Evaluate(SerialNumber, RawText) then begin
            BaseDate := DMY2Date(1, 1, 1900);
            BaseDate := BaseDate + SerialNumber - 1;
            exit(BaseDate);
        end;

        exit(0D);
    end;

    local procedure GetColumnValue(Columns: List of [Text]; ColumnNo: Integer): Text
    begin
        if ColumnNo <= Columns.Count then
            exit(Columns.Get(ColumnNo));

        exit('');
    end;

    local procedure GetColumnDateValue(Columns: List of [Text]; ColumnNo: Integer): Date
    begin
        exit(ParseDateText(GetColumnValue(Columns, ColumnNo)));
    end;

    local procedure DetectCsvDelimiter(HeaderLine: Text): Text[1]
    begin
        if CountOccurrences(HeaderLine, ';') > CountOccurrences(HeaderLine, ',') then
            exit(';');

        exit(',');
    end;

    local procedure CountOccurrences(SourceText: Text; SubText: Text[1]): Integer
    var
        RemainingText: Text;
        Cnt: Integer;
        Pos: Integer;
    begin
        RemainingText := SourceText;
        Pos := StrPos(RemainingText, SubText);

        while Pos > 0 do begin
            Cnt += 1;
            RemainingText := CopyStr(RemainingText, Pos + 1);
            Pos := StrPos(RemainingText, SubText);
        end;

        exit(Cnt);
    end;

    local procedure SplitCsvLine(LineText: Text; Delimiter: Text[1]): List of [Text]
    var
        Fields: List of [Text];
        CurrentField: Text;
        InQuotes: Boolean;
        CharAt: Text[1];
        i: Integer;
    begin
        for i := 1 to StrLen(LineText) do begin
            CharAt := CopyStr(LineText, i, 1);

            if CharAt = '"' then
                InQuotes := not InQuotes
            else
                if (CharAt = Delimiter) and not InQuotes then begin
                    Fields.Add(DelChr(CurrentField, '<>'));
                    CurrentField := '';
                end else
                    CurrentField += CharAt;
        end;

        Fields.Add(DelChr(CurrentField, '<>'));
        exit(Fields);
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

    local procedure ConvertExcelDateToALDate(ExcelDateText: Text): Date
    var
        SerialNumber: Integer;
        BaseDate: Date;
    begin
        // Try to evaluate as a direct date string first (e.g., "2023-12-25")
        if Evaluate(BaseDate, ExcelDateText) then
            exit(BaseDate);

        // If that fails, treat as Excel serial number
        if Evaluate(SerialNumber, ExcelDateText) then begin
            // Excel dates start from January 1, 1900 (serial number 1)
            // But Excel incorrectly treats 1900 as a leap year, so we subtract 1 for dates after Feb 28, 1900
            BaseDate := DMY2Date(1, 1, 1900);
            BaseDate := BaseDate + SerialNumber - 1;
            exit(BaseDate);
        end;

        // If neither works, return 0D (blank date)
        exit(0D);
    end;
}

