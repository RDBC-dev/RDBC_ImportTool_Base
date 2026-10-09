page 85111 "RDBC_Base_JnlImp_Staging"

{
    PageType = List;
    SourceTable = "RDBC_Base_JnlImp_Staging";
    ApplicationArea = All;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Config, upload, import, configuration package, config pack, rdbc, journal';
    Caption = 'RDBC Imported Journal Lines (Staging Table)';
    // DataCaptionFields = "Data Import Name", "Document Import Type";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { Editable = false; }
                field("Data Import Name"; Rec."Data Import Name") { Editable = false; }
                field(Validated; Rec.Validated) { Editable = false; }
                field("Last Validation Error"; Rec."Last Validation Error") { Editable = false; Visible = ShowValidationFields; }
                field(Processed; Rec.Processed) { Editable = false; }
                field("Last Processing Error"; Rec."Last Processing Error") { Editable = false; Visible = ShowProcessingFields; }
                field("Document Created"; Rec."Document Created") { Editable = false; }
                field(Posted; Rec.Posted) { Visible = not ShowValidationFields; Editable = false; }
                field("Journal Import Type"; Rec."Journal Import Type") { }
                field("Journal Batch Name"; Rec."Journal Batch Name") { Editable = true; }
                field("Posting Date"; Rec."Posting Date") { Editable = false; }
                field("Document No."; Rec."Document No.") { Editable = IsEditable; }
                field(Type; Rec.Type) { Editable = IsEditable; }
                field("No."; Rec."No.") { Editable = IsEditable; }
                field(Description; Rec.Description) { Editable = IsEditable; }
                field("Comment"; Rec.Comment) { Editable = IsEditable; }
                field("Currency Code"; Rec."Currency Code") { Editable = IsEditable; }
                field("Amount"; Rec.Amount) { Editable = IsEditable; }
                field("Amount LCY"; Rec."Amount LCY") { Editable = IsEditable; }
                field("Bal. Account Type"; Rec."Bal. Account Type") { Editable = IsEditable; }
                field("Bal. Account No"; Rec."Bal. Account No.") { Editable = IsEditable; }
                field("Shortcut Dimension 1"; Rec."Shortcut Dimension 1") { Editable = IsEditable; }
                field("Shortcut Dimension 2"; Rec."Shortcut Dimension 2") { Editable = IsEditable; }
                field("Shortcut Dimension 3"; Rec."Shortcut Dimension 3") { Editable = IsEditable; }
                field("Shortcut Dimension 4"; Rec."Shortcut Dimension 4") { Editable = IsEditable; }
                field("Shortcut Dimension 5"; Rec."Shortcut Dimension 5") { Editable = IsEditable; }
                field("Shortcut Dimension 6"; Rec."Shortcut Dimension 6") { Editable = IsEditable; }
                field("Shortcut Dimension 7"; Rec."Shortcut Dimension 7") { Editable = IsEditable; }
                field("Shortcut Dimension 8"; Rec."Shortcut Dimension 8") { Editable = IsEditable; }
                field("BU"; Rec.BU) { Editable = IsEditable; } // BUSINESSUNIT DIMENSION
                field("Applies-to Invoice No."; Rec."Applies-to Invoice No.") { Editable = IsEditable; }

            }
        }
    }
    actions
    {

        area(Processing)
        {
            action(ValidateLines)
            {
                Caption = 'Validate Lines';
                Image = CompleteLine;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = ShowValidationFields;

                trigger OnAction()
                var
                    ValidationMgt: Codeunit "RDBC_Base_JnlImpValidationMgt";
                    Staging: Record "RDBC_Base_JnlImp_Staging";
                    ErrorCount: Integer;

                begin
                    Staging.Copy(Rec);
                    Staging.SetRange(Validated, false);
                    Staging.SetRange(Processed, false);

                    // ✅ Ensure there are records
                    if not Staging.FindFirst() then begin
                        Message('No records available for validation.');
                        exit;
                    end;

                    // ✅ Pass filtered dataset to validation
                    ValidationMgt.ValidateAndHandleResult(Staging);

                    CurrPage.Update(false);
                end;

            }

            action(ProcessValidated)
            {
                Caption = 'Process Validated Lines';
                ToolTip = 'Process validated lines with the same Data Import Name as the currently selected line.';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = ShowProcessingFields;

                trigger OnAction()
                var
                    ProcessMgt: Codeunit "RDBC_Base_JnlImpProcessMgt";
                    StagingRec: Record "RDBC_Base_JnlImp_Staging";
                begin
                    // Copy current page filters
                    StagingRec.Copy(Rec);

                    // Process only what is currently visible / filtered
                    ProcessMgt.ProcessValidatedJnlLines(StagingRec);

                    CurrPage.Update(false);
                end;
            }
            action(ShowRelatedEntries)
            {
                Caption = 'Show Data Import Related Entries';
                ToolTip = 'Show all Entries that have the same Data Import Name as the selected entry';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = not ShowValidationFields;

                trigger OnAction()
                var
                    NavigatePage: Page "RDBC_Base_Related_Entries";
                begin
                    // Pass the current line's Data Import Name to the page
                    NavigatePage.SetImportName(Rec."Data Import Name");

                    // Run the page
                    NavigatePage.Run();
                end;
            }
        }
    }
    var
        ShowValidationFields: Boolean;
        ShowProcessingFields: Boolean;
        IsEditable: Boolean;

    procedure SetValidationView()
    begin
        ShowValidationFields := true;
        ShowProcessingFields := false;
    end;

    procedure SetProcessingView()
    begin
        ShowValidationFields := false;
        ShowProcessingFields := true;
    end;

    trigger OnAfterGetRecord()
    begin
        // Check your specific condition here. 
        // For example: if the line is already Processed or Posted, lock it.
        if Rec.Processed or Rec.Posted then
            IsEditable := false
        else
            IsEditable := true;
    end;
}