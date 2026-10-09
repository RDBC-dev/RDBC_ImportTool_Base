page 85104 "RDBC_Base_DocImpRC_Cue"
{
    PageType = CardPart;
    SourceTable = "RDBC_Base_DocImp_Staging";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Import Tool';

    layout
    {
        area(Content)
        {
            cuegroup("Document Imports")
            {
                Visible = ShowDocTiles;

                // Validation Errors
                field("Validation Errors"; ValidationErrorCount)
                {
                    Caption = 'Not validated';
                    ToolTip = 'Open a list of all imported lines that have validation errors';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Funnel;


                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_DocImp_Staging";
                        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
                    begin
                        Staging.SetRange(Validated, false);
                        StagingPage.SetValidationView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }

                // Validated Not Processed
                field("Validated Not Processed"; ValidatedNotProcessedCount)
                {
                    Caption = 'Not processed';
                    ToolTip = 'Open a list of all imported lines that were validated but have processing errors';
                    DrillDown = true;
                    ApplicationArea = All;
                    Image = Checklist;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_DocImp_Staging";
                        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
                    begin
                        Staging.SetRange(Validated, true);
                        Staging.SetRange(Processed, false);

                        StagingPage.SetProcessingView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }
                field("Documents Staging"; ValidationAllDocCount)
                {
                    Caption = 'Imported';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Time;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_DocImp_Staging";
                        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
                    begin
                        StagingPage.Run();
                    end;
                }

            }

            cuegroup("Journal Imports")
            {
                Visible = ShowJnlTiles;

                // Validation Errors
                field("Jnl Validation Errors"; ValidationJnlErrorCount)
                {
                    Caption = 'Not validated';
                    ToolTip = 'Open a list of all imported lines that have validation errors';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Funnel;


                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_JnlImp_Staging";
                        StagingPage: Page "RDBC_Base_JnlImp_Staging";
                    begin
                        Staging.SetRange(Validated, false);

                        StagingPage.SetValidationView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }

                // Validated Not Processed
                field("Jnl Validated Not Processed"; ValidatedJnlNotProcessedCount)
                {
                    Caption = 'Not processed';
                    ToolTip = 'Open a list of all imported lines that were validated but have processing errors';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Checklist;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_JnlImp_Staging";
                        StagingPage: Page "RDBC_Base_JnlImp_Staging";
                    begin
                        Staging.SetRange(Validated, true);
                        Staging.SetRange(Processed, false);

                        StagingPage.SetProcessingView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }

                field("Journal Staging"; ValidationAllJnlCount)
                {
                    Caption = 'Imported';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Time;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_JnlImp_Staging";
                        StagingPage: Page "RDBC_Base_JnlImp_Staging";
                    begin
                        StagingPage.Run();
                    end;
                }
            }
            cuegroup("Upload Options")
            {
                actions
                {
                    // This will render with the "+" sign
                    action(NewDocImport)
                    {
                        ApplicationArea = All;
                        Caption = 'Document Import';
                        ToolTip = 'Create new sales or purchase documents.';
                        Image = TileNew;
                        Visible = ShowDocTiles;
                        RunObject = page RDBC_Base_DocImpExcel;
                        RunPageMode = Create; // <-- THIS is the magic property that makes the "+" icon appear
                    }
                    action(NewJnlImport)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Import';
                        ToolTip = 'Create new journal entries.';
                        Image = TileNew;
                        Visible = ShowJnlTiles;
                        RunObject = page RDBC_Base_JnlImpExcel;
                        RunPageMode = Create; // <-- THIS is the magic property that makes the "+" icon appear
                    }
                }
            }
        }
    }

    var
        ValidationErrorCount: Integer;
        ValidationJnlErrorCount: Integer;
        ValidatedNotProcessedCount: Integer;
        ValidatedJnlNotProcessedCount: Integer;
        ValidationAllJnlCount: Integer;
        ValidationAllDocCount: Integer;
        MyImportsCount: Integer;
        ImportTile: Integer;
        ShowJnlTiles: Boolean;
        ShowDocTiles: Boolean;

    trigger OnOpenPage()
    var
        Features: Codeunit "RDBC_Base_Features";
    begin
        // Tiles are shown only for the import areas that are allowed (Allow Document/Journal Upload)
        ShowDocTiles := Features.IsDocumentUploadAllowed();
        ShowJnlTiles := Features.IsJournalUploadAllowed();
        CurrPage.Caption := Features.GetCaption(CurrPage.Caption);

        // SourceTable is temporary and only used to satisfy the Card Part's need for a
        // current record - without it, the cue renders blank whenever the real staging
        // table has no rows, regardless of the counts computed below.
        Rec.Init();
        Rec.Insert();
        UpdateCounts();
        UpdateJnlCounts();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateCounts();
        UpdateJnlCounts();
    end;

    local procedure UpdateCounts()
    var
        Staging: Record "RDBC_Base_DocImp_Staging";
    begin
        // Count Validation Errors
        Staging.Reset();
        Staging.SetRange(Validated, false);
        ValidationErrorCount := Staging.Count();

        // Count Validated Not Processed
        Staging.Reset();
        Staging.SetRange(Validated, true);
        Staging.SetRange(Processed, false);
        ValidatedNotProcessedCount := Staging.Count();

        Staging.Reset();
        ValidationAllDocCount := Staging.Count();
    end;

    local procedure UpdateJnlCounts()
    var
        Staging: Record "RDBC_Base_JnlImp_Staging";
    begin
        // Count Validation Errors
        Staging.Reset();
        Staging.SetRange(Validated, false);
        ValidationJnlErrorCount := Staging.Count();

        // Count Validated Not Processed
        Staging.Reset();
        Staging.SetRange(Validated, true);
        Staging.SetRange(Processed, false);
        ValidatedJnlNotProcessedCount := Staging.Count();

        Staging.Reset();
        ValidationAllJnlCount := Staging.Count();
    end;

}


page 85103 "RDBC_Base_DocImp_Cues"
{
    PageType = CardPart;
    SourceTable = "RDBC_Base_DocImp_Staging";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Document Import';

    layout
    {
        area(Content)
        {
            cuegroup("Document Import")
            {
                Visible = ShowDocTiles;

                // Validation Errors
                field("Validation Errors"; ValidationErrorCount)
                {
                    Caption = 'Not validated';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Funnel;


                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_DocImp_Staging";
                        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
                    begin
                        Staging.SetRange(Validated, false);

                        StagingPage.SetValidationView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }

                // Validated Not Processed
                field("Validated Not Processed"; ValidatedNotProcessedCount)
                {
                    Caption = 'Not processed';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Checklist;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_DocImp_Staging";
                        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
                    begin
                        Staging.SetRange(Validated, true);
                        Staging.SetRange(Processed, false);

                        StagingPage.SetProcessingView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }
                field("JnlStaging"; ValidationAllCount)
                {
                    Caption = 'Imported';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Time;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_DocImp_Staging";
                        StagingPage: Page "RDBC_Base_Doc_Imp_Staging";
                    begin
                        StagingPage.Run();
                    end;
                }

            }
            cuegroup("Journal Import")
            {
                Visible = ShowJnlTiles;

                field("Import Journal"; ImportTile)
                {
                    Caption = 'Import Journal Lines';
                    ApplicationArea = All;
                    DrillDown = true;
                    Editable = false;
                    Image = Library;
                    BlankZero = true;
                    Style = Strong;
                    ToolTip = 'Upload an Excel to import Journal lines.';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"RDBC_Base_JnlImpExcel");
                    end;
                }
            }
        }
    }

    var
        ValidationErrorCount: Integer;
        ValidatedNotProcessedCount: Integer;
        ValidationAllCount: Integer;
        MyImportsCount: Integer;
        ImportTile: Integer;
        ShowJnlTiles: Boolean;
        ShowDocTiles: Boolean;

    trigger OnOpenPage()
    var
        Features: Codeunit "RDBC_Base_Features";
    begin
        // Tiles are shown only for the import areas that are allowed (Allow Document/Journal Upload)
        ShowDocTiles := Features.IsDocumentUploadAllowed();
        ShowJnlTiles := Features.IsJournalUploadAllowed();
        CurrPage.Caption := Features.GetCaption(CurrPage.Caption);

        // SourceTable is temporary and only used to satisfy the Card Part's need for a
        // current record - without it, the cue renders blank whenever the real staging
        // table has no rows, regardless of the counts computed below.
        Rec.Init();
        Rec.Insert();
        UpdateCounts();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateCounts();
    end;

    local procedure UpdateCounts()
    var
        Staging: Record "RDBC_Base_DocImp_Staging";
    begin
        // Count Validation Errors
        Staging.Reset();
        Staging.SetRange(Validated, false);
        ValidationErrorCount := Staging.Count();

        // Count Validated Not Processed
        Staging.Reset();
        Staging.SetRange(Validated, true);
        Staging.SetRange(Processed, false);
        ValidatedNotProcessedCount := Staging.Count();

        // Count All Lines
        Staging.Reset();
        ValidationAllCount := Staging.Count();
    end;

}

page 85105 "RDBC_Base_JnlImp_Cues"
{
    PageType = CardPart;
    SourceTable = "RDBC_Base_JnlImp_Staging";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Journal Import Tool';

    layout
    {
        area(Content)
        {
            cuegroup("Journal Import")
            {
                Visible = ShowJnlTiles;

                // Validation Errors
                field("Validation Errors"; ValidationErrorCount)
                {
                    Caption = 'Not validated';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Funnel;


                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_JnlImp_Staging";
                        StagingPage: Page "RDBC_Base_JnlImp_Staging";
                    begin
                        Staging.SetRange(Validated, false);

                        StagingPage.SetValidationView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }

                // Validated Not Processed
                field("Validated Not Processed"; ValidatedNotProcessedCount)
                {
                    Caption = 'Not processed';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Checklist;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_JnlImp_Staging";
                        StagingPage: Page "RDBC_Base_JnlImp_Staging";
                    begin
                        Staging.SetRange(Validated, true);
                        Staging.SetRange(Processed, false);

                        StagingPage.SetProcessingView();   // set view mode
                        StagingPage.SetTableView(Staging);
                        StagingPage.Run();
                    end;
                }
                field("JnlStaging"; ValidationAllCount)
                {
                    Caption = 'Imported';
                    ApplicationArea = All;
                    DrillDown = true;
                    Image = Time;

                    trigger OnDrillDown()
                    var
                        Staging: Record "RDBC_Base_JnlImp_Staging";
                        StagingPage: Page "RDBC_Base_JnlImp_Staging";
                    begin
                        StagingPage.Run();
                    end;
                }

            }
            cuegroup("Document Import")
            {
                Visible = ShowDocTiles;

                field("Import Documents"; ImportTile)
                {
                    Caption = 'Import Document Lines';
                    ApplicationArea = All;
                    DrillDown = true;
                    Editable = false;
                    Image = Receipt;
                    BlankZero = true;
                    Style = Strong;
                    ToolTip = 'Upload an Excel to import Document lines.';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"RDBC_Base_DocImpExcel");
                    end;
                }
            }
        }
    }

    var
        ValidationErrorCount: Integer;
        ValidatedNotProcessedCount: Integer;
        ValidationAllCount: Integer;
        MyImportsCount: Integer;
        ImportTile: Integer;
        ShowJnlTiles: Boolean;
        ShowDocTiles: Boolean;

    trigger OnOpenPage()
    var
        Features: Codeunit "RDBC_Base_Features";
    begin
        // Tiles are shown only for the import areas that are allowed (Allow Document/Journal Upload)
        ShowDocTiles := Features.IsDocumentUploadAllowed();
        ShowJnlTiles := Features.IsJournalUploadAllowed();
        CurrPage.Caption := Features.GetCaption(CurrPage.Caption);

        // SourceTable is temporary and only used to satisfy the Card Part's need for a
        // current record - without it, the cue renders blank whenever the real staging
        // table has no rows, regardless of the counts computed below.
        Rec.Init();
        Rec.Insert();
        UpdateCounts();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateCounts();
    end;

    local procedure UpdateCounts()
    var
        Staging: Record "RDBC_Base_JnlImp_Staging";
    begin
        // Count Validation Errors
        Staging.Reset();
        Staging.SetRange(Validated, false);
        ValidationErrorCount := Staging.Count();

        // Count Validated Not Processed
        Staging.Reset();
        Staging.SetRange(Validated, true);
        Staging.SetRange(Processed, false);
        ValidatedNotProcessedCount := Staging.Count();

        // Count All Lines
        Staging.Reset();
        ValidationAllCount := Staging.Count();

    end;

}