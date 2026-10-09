// Helper procedures for customer-specific extensions, so they do not have to copy base logic.
codeunit 85161 "RDBC_Base_ImportHelper"
{
    // Appends an error to the validation error text of a staging line.
    procedure AddError(var ErrorText: Text[1024]; NewError: Text)
    begin
        if ErrorText = '' then
            ErrorText := CopyStr(NewError, 1, MaxStrLen(ErrorText))
        else
            ErrorText := CopyStr(ErrorText + ' | ' + NewError, 1, MaxStrLen(ErrorText));
    end;

    // Checks that a dimension and its value exist and the value is not blocked.
    procedure ValidateDimensionValue(DimCode: Code[20]; DimValueCode: Code[20]; var ErrorText: Text[1024])
    var
        Dim: Record Dimension;
        DimValue: Record "Dimension Value";
    begin
        if DimValueCode = '' then
            exit;

        if not Dim.Get(DimCode) then begin
            AddError(ErrorText, StrSubstNo('Dimension %1 does not exist.', DimCode));
            exit;
        end;

        if not DimValue.Get(DimCode, DimValueCode) then begin
            AddError(ErrorText, StrSubstNo('Dimension value %1 does not exist in dimension %2.', DimValueCode, DimCode));
            exit;
        end;

        if DimValue.Blocked then
            AddError(ErrorText, StrSubstNo('Dimension value %1 in dimension %2 is blocked.', DimValueCode, DimCode));
    end;

    // Sets (or replaces) one dimension in a temporary dimension set.
    procedure SetDimension(var TempDimSetEntry: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValueCode: Code[20])
    var
        DimValue: Record "Dimension Value";
    begin
        if (DimCode = '') or (DimValueCode = '') then
            exit;

        if not DimValue.Get(DimCode, DimValueCode) then
            Error('Dimension value %1 does not exist in dimension %2.', DimValueCode, DimCode);

        TempDimSetEntry.SetRange("Dimension Code", DimCode);
        TempDimSetEntry.DeleteAll();
        TempDimSetEntry.SetRange("Dimension Code");

        TempDimSetEntry.Init();
        TempDimSetEntry."Dimension Code" := DimCode;
        TempDimSetEntry."Dimension Value Code" := DimValueCode;
        TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
        TempDimSetEntry.Insert();
    end;
}
