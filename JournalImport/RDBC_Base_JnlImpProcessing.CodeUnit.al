codeunit 85132 "RDBC_Base_JnlImpProcessMgt"
{
    procedure ProcessValidatedJnlLines(var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        DataImportName: Text[50];
        CheckRec: Record "RDBC_Base_JnlImp_Staging";

        GenJnl: Record "Gen. Journal Line";
        GenJnlTemplateName: Code[10];
        GenJnlBatchName: Code[10];

        MessageText: Text;
        Choice: Integer;
        ProgressDialog: Dialog;
        TotalGroups: Integer;
        ProcessedGroups: Integer;
        ProgressPercent: Integer;
        MessageRefreshInterval: Duration;
        LastMessageUpdateAt: DateTime;
        MoreGroups: Boolean;

    begin
        DataImportName := Staging."Data Import Name";

        GenJnlTemplateName := 'GENERAL';
        GenJnlBatchName := Staging."Journal Batch Name";

        GenJnl.Reset();
        GenJnl.SetRange("Journal Template Name", GenJnlTemplateName);
        GenJnl.SetRange("Journal Batch Name", GenJnlBatchName);

        if not GenJnl.IsEmpty() then begin

            MessageText :=
              StrSubstNo(
                'The batch %1 > %2 already contains lines.\' +
                'What would you like to do?',
                GenJnlTemplateName,
                GenJnlBatchName);

            Choice :=
              StrMenu(
                'Open the Journal,Append to existing Journal Lines,Overwrite existing Journal Lines,Cancel',
                4,
                MessageText);

            case Choice of
                1:
                    begin
                        // Open the journal and stop
                        Page.Run(Page::"General Journal", GenJnl);
                        exit;
                    end;
                2:
                    // Append → keep existing lines and add new ones below
                    ;
                3:
                    begin
                        // Overwrite → delete all existing lines in this batch first
                        if not Confirm(
                            'This will delete ALL existing lines in batch %1 > %2 before importing.\Are you sure?',
                            false,
                            GenJnlTemplateName,
                            GenJnlBatchName) then
                            exit;
                        GenJnl.DeleteAll();
                    end;
                4:
                    exit;  // Cancel
            end;
        end;

        // Ensure ALL lines in batch are validated and not processed
        CheckRec.Reset();
        CheckRec.SetRange("Data Import Name", DataImportName);

        if not CheckRec.FindSet() then
            exit;  // nothing to process

        repeat
            if (not CheckRec.Validated) then begin
                Message(
                    'Processing cannot start.\Make sure that all lines for Data Import %1 are validated.',
                    DataImportName);
                exit;
            end;
        until CheckRec.Next() = 0;

        // Now filter only the lines to process
        Staging.Reset();

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetRange(Validated, true);
        Staging.SetRange(Processed, false);

        Staging.SetCurrentKey("Journal Import Type", "Journal Batch Name", "Document No.");

        ProgressDialog.Open(
            GetProgressDialogFormat(
                'Processing journal lines...',
                StrLen(BuildProgressBar(100)),
                GetLongestJnlProgressMessageLength())
        );
        ProgressDialog.Update(1, BuildProgressBar(0));
        ProgressDialog.Update(2, 'Preparing journal lines...');

        if not Staging.FindSet() then begin
            ProgressDialog.Close();
            Message(
                'No validated lines are pending processing for Data Import %1.',
                DataImportName);
            exit;
        end;

        Randomize();
        TotalGroups := CountPendingJnlGroups(Staging);
        ProcessedGroups := 0;
        MessageRefreshInterval := 5000;
        LastMessageUpdateAt := CurrentDateTime;
        ProgressDialog.Update(2, GetRandomJnlProgressMessage());

        MoreGroups := true;
        while MoreGroups do begin
            ProcessedGroups += 1;
            if TotalGroups > 0 then
                ProgressPercent := Round((ProcessedGroups * 100) / TotalGroups, 1, '=')
            else
                ProgressPercent := 0;

            ProgressDialog.Update(1, BuildProgressBar(ProgressPercent));
            if (CurrentDateTime - LastMessageUpdateAt) >= MessageRefreshInterval then begin
                ProgressDialog.Update(2, GetRandomJnlProgressMessage());
                LastMessageUpdateAt := CurrentDateTime;
            end;

            ProcessDocumentGroup(Staging);
            // SkipGroup already advances the cursor onto the first record of the next group (or
            // reports there is none) - it, and only it, owns cursor advancement here. A second,
            // independent Next() call in this loop would skip that first record without ever
            // processing it, which is exactly what happened before this fix.
            MoreGroups := SkipGroup(Staging);
        end;

        ProgressDialog.Close();

        // Show result based on Document Type
        case Staging."Journal Import Type" of

            Staging."Journal Import Type"::"General":
                ShowProcessingResultForGeneralJournal(DataImportName);

            Staging."Journal Import Type"::"Sales Payment":
                ShowProcessingResultForSalesPayment(DataImportName);

            Staging."Journal Import Type"::"Purchase Payment":
                ShowProcessingResultForPurchasePayment(DataImportName);
        end;

    end;

    local procedure ProcessDocumentGroup(var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        GroupRec: Record "RDBC_Base_JnlImp_Staging";
        Processor: Codeunit "RDBC_Base_GenJournalProcessor";

    begin
        GetGroup(Staging, GroupRec);

        if not AllLinesValidated(GroupRec) then
            exit;

        case Staging."Journal Import Type" of

            Staging."Journal Import Type"::"General":
                ProcessGeneralJournal(GroupRec, Staging);

            Staging."Journal Import Type"::"Sales Payment":
                ProcessGeneralJournal(GroupRec, Staging);

            Staging."Journal Import Type"::"Purchase Payment":
                ProcessGeneralJournal(GroupRec, Staging);
        end;
    end;

    // ****************************************************************************************
    #REGION JOURNAL TYPE SPECIFIC PROCSEEING PROCEDURES    
    local procedure ProcessGeneralJournal(
        var GroupRec: Record "RDBC_Base_JnlImp_Staging";
        var Staging: Record "RDBC_Base_JnlImp_Staging")
    var
        Processor: Codeunit "RDBC_Base_GenJournalProcessor";
        DocNo: Code[20];
    begin
        if not Processor.Process(GroupRec, Staging, DocNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, DocNo);
    end;

    #ENDREGION JOURNAL TYPE SPECIFIC PROCSEEING PROCEDURES
    // ****************************************************************************************

    // ****************************************************************************************
    #REGION HELPER PROCEDURES
    // Filters Staging table into processing batches with same 
    // Business Relation No. and External Document Number
    local procedure GetGroup(var SourceRec: Record "RDBC_Base_JnlImp_Staging"; var GroupRec: Record "RDBC_Base_JnlImp_Staging")
    begin
        GroupRec.Reset();

        GroupRec.SetRange("Data Import Name", SourceRec."Data Import Name");
        GroupRec.SetRange("Journal Import Type", SourceRec."Journal Import Type");
        GroupRec.SetRange("Journal Batch Name", SourceRec."Journal Batch Name");
        GroupRec.SetRange("Document No.", SourceRec."Document No.");
        GroupRec.SetRange(Processed, false);
    end;

    local procedure AllLinesValidated(var GroupRec: Record "RDBC_Base_JnlImp_Staging"): Boolean
    begin
        if GroupRec.FindSet() then
            repeat
                if not GroupRec.Validated then
                    exit(false);
            until GroupRec.Next() = 0;

        exit(true);
    end;

    // Advances Staging past every remaining sibling line of the group that was just processed.
    // Returns true when it lands on a genuine next group (the caller must process it), or false
    // when there are no more records at all. The caller must not call Next() again afterwards -
    // this procedure already consumed the first record of the next group while checking for the
    // group boundary, so a second Next() would skip that record without ever processing it.
    local procedure SkipGroup(var Staging: Record "RDBC_Base_JnlImp_Staging"): Boolean
    var
        JnlType: Enum "RDBC_Base_JnlImpType";
        JnlBatch: Code[10];
        DocNo: Code[20];
        HasNext: Boolean;
    begin
        JnlType := Staging."Journal Import Type";
        JnlBatch := Staging."Journal Batch Name";
        DocNo := Staging."Document No.";

        HasNext := Staging.Next() <> 0;
        while HasNext and
              (Staging."Journal Import Type" = JnlType) and
              (Staging."Journal Batch Name" = JnlBatch) and
              (Staging."Document No." = DocNo) do
            HasNext := Staging.Next() <> 0;

        exit(HasNext);
    end;

    local procedure MarkGroupAsProcessed(var GroupRec: Record "RDBC_Base_JnlImp_Staging"; DocNo: Code[20])
    begin
        if GroupRec.FindSet() then
            repeat
                GroupRec.Processed := true;
                GroupRec."Last Processing Error" := '';
                GroupRec."Document Created" := DocNo;
                GroupRec.Modify();
            until GroupRec.Next() = 0;
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

    local procedure ShowProcessingResultForGeneralJournal(DataImportName: Text[50])
    var
        //PurchHeader: Record "Purchase Header";
        GenJnl: Record "Gen. Journal Line";
        Staging: Record "RDBC_Base_JnlImp_Staging";
        ConfirmMsg: Text;
    begin
        GenJnl.SetRange("Journal Template Name", 'GENERAL');
        GenJnl.SetRange("RDBC_Base_Data Import Name", DataImportName);

        // if PurchHeader.IsEmpty() then begin
        //     Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
        //     exit;
        // end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Journal Lines were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'The Journal was created successfully.\Do you want to open it?\\Please be aware that the Journal will be filtered to the Data Import Name you provided for this import.';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"General Journal", GenJnl);
            end;
        end;
    end;

    local procedure ShowProcessingResultForSalesPayment(DataImportName: Text[50])
    var
        Staging: Record "RDBC_Base_JnlImp_Staging";
        GenJnl: Record "Gen. Journal Line";
    begin
        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');

        if not Staging.IsEmpty() then begin
            Message('Some payment lines failed during processing. Please review the staging table and fix the errors.');
            exit;
        end;

        GenJnl.SetRange("Journal Template Name", 'GENERAL');
        GenJnl.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if Confirm('Sales Payment journal lines were created but not posted.\Do you want to open the Journal to review and post them?', false) then
            Page.Run(Page::"General Journal", GenJnl);
    end;

    local procedure ShowProcessingResultForPurchasePayment(DataImportName: Text[50])
    var
        Staging: Record "RDBC_Base_JnlImp_Staging";
        GenJnl: Record "Gen. Journal Line";
    begin
        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');

        if not Staging.IsEmpty() then begin
            Message('Some payment lines failed during processing. Please review the staging table and fix the errors.');
            exit;
        end;

        GenJnl.SetRange("Journal Template Name", 'GENERAL');
        GenJnl.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if Confirm('Purchase Payment journal lines were created but not posted.\Do you want to open the Journal to review and post them?', false) then
            Page.Run(Page::"General Journal", GenJnl);
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
        StagingPage: Page "RDBC_Base_jnlImp_Staging";
    begin
        StagingPage.SetProcessingView();
        StagingPage.SetTableView(Staging);
        StagingPage.Run();
    end;

    #ENDREGION HELPER PROCEDURES

    local procedure CountPendingJnlGroups(var Staging: Record "RDBC_Base_JnlImp_Staging"): Integer
    var
        CountRec: Record "RDBC_Base_JnlImp_Staging";
        LastJnlType: Enum "RDBC_Base_JnlImpType";
        LastBatchName: Code[10];
        LastDocNo: Code[20];
        IsFirstRecord: Boolean;
        GroupCount: Integer;
    begin
        CountRec.Copy(Staging);

        if not CountRec.FindSet() then
            exit(0);

        IsFirstRecord := true;

        repeat
            if IsFirstRecord or
               (CountRec."Journal Import Type" <> LastJnlType) or
               (CountRec."Journal Batch Name" <> LastBatchName) or
               (CountRec."Document No." <> LastDocNo) then begin
                GroupCount += 1;
                LastJnlType := CountRec."Journal Import Type";
                LastBatchName := CountRec."Journal Batch Name";
                LastDocNo := CountRec."Document No.";
                IsFirstRecord := false;
            end;
        until CountRec.Next() = 0;

        exit(GroupCount);
    end;

    local procedure BuildProgressBar(Percent: Integer): Text
    var
        BarWidth: Integer;
        FilledCount: Integer;
        EmptyCount: Integer;
        Bar: Text;
        i: Integer;
    begin
        BarWidth := 20;
        FilledCount := Round(Percent * BarWidth / 100, 1, '<');
        EmptyCount := BarWidth - FilledCount;

        Bar := '[';
        for i := 1 to FilledCount do
            Bar += '=';
        for i := 1 to EmptyCount do
            Bar += '-';
        Bar += '] ' + Format(Percent) + '%';

        exit(Bar);
    end;

    local procedure GetProgressDialogFormat(DialogTitle: Text; BarPlaceholderWidth: Integer; MessagePlaceholderWidth: Integer): Text
    begin
        exit(
            DialogTitle + '\\' +
            '#1' + PadStr('', BarPlaceholderWidth, '#') + '\\' +
            '#2' + PadStr('', MessagePlaceholderWidth, '#'));
    end;

    local procedure GetLongestJnlProgressMessageLength(): Integer
    var
        Messages: List of [Text];
        MessageText: Text;
        LongestMessageLength: Integer;
    begin
        Messages := GetJnlProgressMessages();
        LongestMessageLength := StrLen('Preparing journal lines...');

        foreach MessageText in Messages do
            if StrLen(MessageText) > LongestMessageLength then
                LongestMessageLength := StrLen(MessageText);

        exit(LongestMessageLength);
    end;

    local procedure GetRandomJnlProgressMessage(): Text
    var
        Messages: List of [Text];
        MessageIndex: Integer;
    begin
        Messages := GetJnlProgressMessages();

        if Messages.Count() = 0 then
            exit('Processing journal lines...');

        MessageIndex := Random(Messages.Count());
        exit(Messages.Get(MessageIndex));
    end;

    local procedure GetJnlProgressMessages(): List of [Text]
    var
        Events: Codeunit "RDBC_Base_Events";
        Messages: List of [Text];
        IsHandled: Boolean;
    begin
        // Customer extensions can replace these texts (OnGetJournalProgressMessages)
        Events.OnGetJournalProgressMessages(Messages, IsHandled);
        if IsHandled then
            exit(Messages);

        Messages.Add('Doing the thing...');
        Messages.Add('Making progress... allegedly...');
        Messages.Add('Working hard, or hardly working...');
        Messages.Add('Convincing the computer to cooperate...');
        Messages.Add('Moving things around...');
        Messages.Add('Putting everything in its proper place...');
        Messages.Add('Making the magic happen...');
        Messages.Add('Consulting the digital oracle...');
        Messages.Add('Crunching some numbers... probably...');
        Messages.Add('Turning coffee into progress...');
        Messages.Add('Processing important computer stuff...');
        Messages.Add('Shuffling bits and pieces...');
        Messages.Add('Making things slightly more organized...');
        Messages.Add('Checking, double-checking, and checking again...');
        Messages.Add('Counting things just to be sure...');
        Messages.Add('Looking busy while doing something useful...');
        Messages.Add('Making progress at an impressive-looking pace...');
        Messages.Add('Asking nicely for things to cooperate...');
        Messages.Add('Untangling the digital spaghetti...');
        Messages.Add('Putting the pieces together...');
        Messages.Add('Sorting out the complicated bits...');
        Messages.Add('Making sense of the nonsense...');
        Messages.Add('Keeping everything under control... mostly...');
        Messages.Add('Doing some behind-the-scenes wizardry...');
        Messages.Add('Performing highly technical button pressing...');
        Messages.Add('Moving electrons with purpose...');
        Messages.Add('Encouraging the data to move along...');
        Messages.Add('Giving the system something to think about...');
        Messages.Add('Making sure nothing catches fire...');
        Messages.Add('Checking whether everything still exists...');
        Messages.Add('Looking for the thing we need...');
        Messages.Add('Finding things that were apparently hiding...');
        Messages.Add('Putting things where they probably belong...');
        Messages.Add('Removing digital dust...');
        Messages.Add('Polishing the details...');
        Messages.Add('Sweeping up the leftovers...');
        Messages.Add('Tidying up the loose ends...');
        Messages.Add('Making the complicated look easy...');
        Messages.Add('Making the easy unnecessarily complicated...');
        Messages.Add('Applying a generous amount of patience...');
        Messages.Add('Waiting very professionally...');
        Messages.Add('Demonstrating exceptional loading skills...');
        Messages.Add('Calculating an appropriate amount of progress...');
        Messages.Add('Generating progress from seemingly nowhere...');
        Messages.Add('Converting waiting time into productivity...');
        Messages.Add('Doing important stuff behind the scenes...');
        Messages.Add('Making impressive noises in the background...');
        Messages.Add('Giving the processor something to do...');
        Messages.Add('Keeping the gears turning...');
        Messages.Add('Turning the wheels of progress...');
        Messages.Add('Pushing a few buttons and hoping for the best...');
        Messages.Add('Trusting the process...');
        Messages.Add('Following the plan... more or less...');
        Messages.Add('Taking the scenic route...');
        Messages.Add('Going the long way around...');
        Messages.Add('Taking care of the boring bits...');
        Messages.Add('Handling the complicated stuff...');
        Messages.Add('Making a few million tiny decisions...');
        Messages.Add('Negotiating with the computer...');
        Messages.Add('Having a quick word with the database...');
        Messages.Add('Asking the data to please cooperate...');
        Messages.Add('Checking the fine print...');
        Messages.Add('Looking under the digital couch...');
        Messages.Add('Searching for loose change...');
        Messages.Add('Herding pixels...');
        Messages.Add('Herding electrons...');
        Messages.Add('Keeping everything moving...');
        Messages.Add('Moving along nicely...');
        Messages.Add('Getting there...');
        Messages.Add('Almost there... probably...');
        Messages.Add('Nearly finished... don''t jinx it...');
        Messages.Add('Just a little longer...');
        Messages.Add('Putting on the finishing touches...');
        Messages.Add('Making sure we didn''t miss anything...');
        Messages.Add('Doing one last thing...');
        Messages.Add('One last last thing...');
        Messages.Add('Definitely almost finished...');
        Messages.Add('Finishing up the finishing up...');
        Messages.Add('Preparing to pretend this was easy...');
        Messages.Add('Wrapping things up...');
        Messages.Add('And now for the exciting conclusion...');
        Messages.Add('Please continue looking productive...');
        Messages.Add('Your patience is being professionally appreciated...');
        Messages.Add('Thank you for not clicking anything...');
        Messages.Add('Everything is under control... probably...');
        Messages.Add('So far, so good...');
        Messages.Add('No news is good news...');
        Messages.Add('Nothing to see here... just progress...');
        Messages.Add('Progress detected...');
        Messages.Add('Progress intensifying...');
        Messages.Add('Maximum progress achieved...');
        Messages.Add('Almost suspiciously efficient...');
        Messages.Add('Working exactly as intended...');
        Messages.Add('Probably working exactly as intended...');
        Messages.Add('This seemed faster in testing...');
        Messages.Add('We''re sure this is necessary...');
        Messages.Add('Because apparently this takes a while...');
        Messages.Add('Please enjoy this exciting loading experience...');
        Messages.Add('Thank you for your continued confidence...');
        Messages.Add('Maintaining an appropriate level of suspense...');
        Messages.Add('Creating suspense at no extra charge...');
        Messages.Add('Keeping you guessing...');
        Messages.Add('Making you wonder what''s taking so long...');
        Messages.Add('Taking exactly as long as expected...');
        Messages.Add('Taking slightly longer than expected...');
        Messages.Add('Recalculating expectations...');
        Messages.Add('Adjusting our definition of ''almost done''...');

        exit(Messages);
    end;
    // ****************************************************************************************




}