codeunit 85122 "RDBC_Base_DocImpProcessMgt"
{
    // Called from the Staging Table Page by click on "Process Validated Lines"ProcessValidatedDocuments
    procedure ProcessValidatedDocuments(var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        Features: Codeunit "RDBC_Base_Features";
        DataImportName: Text[50];
        CheckRec: Record "RDBC_Base_DocImp_Staging";
        ProgressDialog: Dialog;
        TotalGroups: Integer;
        ProcessedGroups: Integer;
        ProgressPercent: Integer;
        ProgressMessages: List of [Text];
        MessageRefreshInterval: Duration;
        LastMessageUpdateAt: DateTime;

        PO: Codeunit "RDBC_Base_PO_Processor";
        PI: Codeunit "RDBC_Base_PI_Processor";
        PCM: Codeunit "RDBC_Base_PCM_Processor";
        SO: Codeunit "RDBC_Base_SO_Processor";
        SI: Codeunit "RDBC_Base_SI_Processor";
        SCM: Codeunit "RDBC_Base_SCM_Processor";
        Events: Codeunit "RDBC_Base_Events";

    begin
        Features.CheckDocumentUploadAllowed();
        DataImportName := Staging."Data Import Name";

        // Ensure ALL lines in batch are validated and not processed
        CheckRec.Reset();
        CheckRec.SetRange("Data Import Name", DataImportName);

        if not CheckRec.FindSet() then
            exit;  // nothing to process

        repeat
            if (not CheckRec.Validated) then begin
                Message(
                    'Processing cannot start.\All lines for batch %1 must be validated.',
                    DataImportName);
                exit;
            end;
        until CheckRec.Next() = 0;

        // Now filter only the lines to process
        Staging.Reset();

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetRange(Validated, true);
        Staging.SetRange(Processed, false);

        Staging.SetCurrentKey("Data Import Name", "Document Import Type", "Business Relation No.", "External Document No.");

        if Staging.FindSet() then begin
            Randomize();
            TotalGroups := CountPendingGroups(Staging);
            ProcessedGroups := 0;
            ProgressMessages := GetProgressMessages();
            MessageRefreshInterval := 5000;
            LastMessageUpdateAt := CurrentDateTime;

            ProgressDialog.Open(
                GetProgressDialogFormat(
                    'Processing documents...',
                    StrLen(BuildProgressBar(100)),
                    GetLongestProgressMessageLength())
                );
            ProgressDialog.Update(2, TakeRandomProgressMessage(ProgressMessages));

            repeat
                ProcessedGroups += 1;
                if TotalGroups > 0 then
                    ProgressPercent := Round((ProcessedGroups * 100) / TotalGroups, 1, '=')
                else
                    ProgressPercent := 0;

                ProgressDialog.Update(1, BuildProgressBar(ProgressPercent));
                if (CurrentDateTime - LastMessageUpdateAt) >= MessageRefreshInterval then begin
                    ProgressDialog.Update(2, TakeRandomProgressMessage(ProgressMessages));
                    LastMessageUpdateAt := CurrentDateTime;
                end;

                ProcessDocumentGroup(Staging);
            until not SkipGroup(Staging);

            ProgressDialog.Close();
        end;

        // Show result based on Document Type
        // 1 of Add new Document Type here
        case Staging."Document Import Type" of

            // Purchase Orders
            Staging."Document Import Type"::"PO":
                PO.ShowProcessingResultForPO(DataImportName);
            //ShowProcessingResultForPO(DataImportName);


            // Purchase Invoices
            Staging."Document Import Type"::"PI":
                PI.ShowProcessingResultForPI(DataImportName);
            //ShowProcessingResultForPI(DataImportName);

            // Purchase Credit Memos
            Staging."Document Import Type"::"PCM":
                PCM.ShowProcessingResultForPCM(DataImportName);
            //ShowProcessingResultForPCM(DataImportName);

            // Sales Order
            Staging."Document Import Type"::"SO":
                SO.ShowProcessingResultForSO(DataImportName);
            //ShowProcessingResultForSO(DataImportName);

            Staging."Document Import Type"::"SI":
                SI.ShowProcessingResultForSI(DataImportName);
            //ShowProcessingResultForSI(DataImportName);

            Staging."Document Import Type"::"SCM":
                SCM.ShowProcessingResultForSCM(DataImportName);
            //ShowProcessingResultForSCM(DataImportName);

            else
                // Document Import Types added by customer extensions (enumextension)
                Events.OnShowProcessingResultCustomDocumentType(Staging."Document Import Type", DataImportName);
        end;

    end;

    local procedure ProcessDocumentGroup(var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        GroupRec: Record "RDBC_Base_DocImp_Staging";
    // Processor: Codeunit "RDBC_Base_CCExpenseProcessor";

    begin
        GetGroup(Staging, GroupRec);

        if not AllLinesValidated(GroupRec) then
            exit;

        case Staging."Document Import Type" of

            Staging."Document Import Type"::"PO":
                Process_PO(GroupRec, Staging);

            Staging."Document Import Type"::"PI":
                Process_PI(GroupRec, Staging);

            Staging."Document Import Type"::"PCM":
                Process_PCM(GroupRec, Staging);

            Staging."Document Import Type"::"SO":
                Process_SO(GroupRec, Staging);

            Staging."Document Import Type"::"SI":
                Process_SI(GroupRec, Staging);

            Staging."Document Import Type"::"SCM":
                Process_SCM(GroupRec, Staging);

            else
                Process_CustomDocumentType(GroupRec, Staging);
        end;
    end;

    // ****************************************************************************************
    #REGION DOCUMENT TYPE SPECIFIC PROCSEEING PROCEDURES    
    local procedure Process_PO(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        //ErrorText: Text[1024];
        Processor: Codeunit "RDBC_Base_PO_Processor";
        PurchNo: Code[20];
    begin
        // Processor.Process(GroupRec, Staging);
        if not Processor.Process(GroupRec, Staging, PurchNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, PurchNo);
    end;

    local procedure Process_PI(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        Processor: Codeunit "RDBC_Base_PI_Processor";
        PurchNo: Code[20];
    begin
        if not Processor.Process(GroupRec, Staging, PurchNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, PurchNo);
    end;

    local procedure Process_PCM(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        //ErrorText: Text[1024];
        Processor: Codeunit "RDBC_Base_PCM_Processor";
        PurchNo: Code[20];
    begin
        // Processor.Process(GroupRec, Staging);
        if not Processor.Process(GroupRec, Staging, PurchNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, PurchNo);
    end;

    local procedure Process_SO(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        Processor: Codeunit "RDBC_Base_SO_Processor";
        SalesNo: Code[20];
    begin
        if not Processor.Process(GroupRec, Staging, SalesNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, SalesNo);
    end;

    local procedure Process_SI(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        Processor: Codeunit "RDBC_Base_SI_Processor";
        SalesNo: Code[20];
    begin
        if not Processor.Process(GroupRec, Staging, SalesNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, SalesNo);
    end;

    local procedure Process_SCM(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        Processor: Codeunit "RDBC_Base_SCM_Processor";
        SalesNo: Code[20];
    begin
        if not Processor.Process(GroupRec, Staging, SalesNo) then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, SalesNo);
    end;


    // Document Import Types added by customer extensions (enumextension)
    local procedure Process_CustomDocumentType(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging")
    var
        Events: Codeunit "RDBC_Base_Events";
        DocumentNo: Code[20];
        Success: Boolean;
        IsHandled: Boolean;
    begin
        Events.OnProcessCustomDocumentType(GroupRec, Staging, DocumentNo, Success, IsHandled);

        if not IsHandled then begin
            LogProcessingError(GroupRec, StrSubstNo('Document Import Type %1 is not supported.', Staging."Document Import Type"));
            exit;
        end;

        if not Success then begin
            LogProcessingError(GroupRec, GetLastErrorText());
            exit;
        end;
        MarkGroupAsProcessed(GroupRec, DocumentNo);
    end;

    #ENDREGION DOCUMENT TYPE SPECIFIC PROCSEEING PROCEDURES
    // ****************************************************************************************

    // ****************************************************************************************
    #REGION HELPER PROCEDURES
    // Filters Staging table into processing batches with same 
    // Business Relation No. and External Document Number
    local procedure GetGroup(var SourceRec: Record "RDBC_Base_DocImp_Staging"; var GroupRec: Record "RDBC_Base_DocImp_Staging")
    begin
        GroupRec.Reset();

        GroupRec.SetRange("Data Import Name", SourceRec."Data Import Name");
        GroupRec.SetRange("Document Import Type", SourceRec."Document Import Type");
        GroupRec.SetRange("Business Relation No.", SourceRec."Business Relation No.");
        GroupRec.SetRange("External Document No.", SourceRec."External Document No.");
        GroupRec.SetRange(Processed, false);
    end;

    local procedure AllLinesValidated(var GroupRec: Record "RDBC_Base_DocImp_Staging"): Boolean
    begin
        if GroupRec.FindSet() then
            repeat
                if not GroupRec.Validated then
                    exit(false);
            until GroupRec.Next() = 0;

        exit(true);
    end;

    local procedure SkipGroup(var Staging: Record "RDBC_Base_DocImp_Staging"): Boolean
    var
        DocType: Enum "RDBC_Base_DocImpType";
        VendorNo: Code[20];
        ExtDocNo: Code[35];
    begin
        DocType := Staging."Document Import Type";
        VendorNo := Staging."Business Relation No.";
        ExtDocNo := Staging."External Document No.";

        // while (Staging.Next() <> 0) and
        //       (Staging."Document Import Type" = DocType) and
        //       (Staging."Business Relation No." = VendorNo) and
        //       (Staging."External Document No." = ExtDocNo) do;
        // Advance past all remaining records in the current group.
        // Returns true (cursor on first record of next group) or false (no more records).
        while Staging.Next() <> 0 do begin
            if (Staging."Document Import Type" <> DocType) or
               (Staging."Business Relation No." <> VendorNo) or
               (Staging."External Document No." <> ExtDocNo) then
                exit(true);
        end;
    end;

    local procedure CountPendingGroups(var Staging: Record "RDBC_Base_DocImp_Staging"): Integer
    var
        CountRec: Record "RDBC_Base_DocImp_Staging";
        LastDocType: Enum "RDBC_Base_DocImpType";
        LastBusinessRelationNo: Code[20];
        LastExternalDocumentNo: Code[35];
        IsFirstRecord: Boolean;
        GroupCount: Integer;
    begin
        CountRec.Copy(Staging);

        if not CountRec.FindSet() then
            exit(0);

        IsFirstRecord := true;

        repeat
            if IsFirstRecord or
               (CountRec."Document Import Type" <> LastDocType) or
               (CountRec."Business Relation No." <> LastBusinessRelationNo) or
               (CountRec."External Document No." <> LastExternalDocumentNo) then begin
                GroupCount += 1;
                LastDocType := CountRec."Document Import Type";
                LastBusinessRelationNo := CountRec."Business Relation No.";
                LastExternalDocumentNo := CountRec."External Document No.";
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

    local procedure GetLongestProgressMessageLength(): Integer
    var
        Messages: List of [Text];
        MessageText: Text;
        LongestMessageLength: Integer;
    begin
        Messages := GetProgressMessages();
        LongestMessageLength := StrLen('Processing documents ...');

        foreach MessageText in Messages do
            if StrLen(MessageText) > LongestMessageLength then
                LongestMessageLength := StrLen(MessageText);

        exit(LongestMessageLength);
    end;

    local procedure TakeRandomProgressMessage(var Messages: List of [Text]): Text
    var
        MessageIndex: Integer;
        SelectedMessage: Text;
    begin
        if Messages.Count() = 0 then
            Messages := GetProgressMessages();

        if Messages.Count() = 0 then
            exit('Processing documents ...');

        MessageIndex := Random(Messages.Count());
        SelectedMessage := Messages.Get(MessageIndex);
        Messages.RemoveAt(MessageIndex);

        exit(SelectedMessage);
    end;

    local procedure GetProgressMessages(): List of [Text]
    var
        Events: Codeunit "RDBC_Base_Events";
        Messages: List of [Text];
        IsHandled: Boolean;
    begin
        // Customer extensions can replace these texts (OnGetDocumentProgressMessages)
        Events.OnGetDocumentProgressMessages(Messages, IsHandled);
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

    local procedure MarkGroupAsProcessed(var GroupRec: Record "RDBC_Base_DocImp_Staging"; PurchNo: Code[20])
    begin
        if GroupRec.FindSet() then
            repeat
                GroupRec.Processed := true;
                GroupRec."Last Processing Error" := '';
                GroupRec."Document Created" := PurchNo;
                GroupRec.Modify();
            until GroupRec.Next() = 0;
    end;

    local procedure LogProcessingError(var GroupRec: Record "RDBC_Base_DocImp_Staging"; ErrorMessage: Text)
    begin
        if GroupRec.FindSet() then
            repeat
                GroupRec."Last Processing Error" :=
                    CopyStr(ErrorMessage, 1, 1024);
                GroupRec.Modify();
            until GroupRec.Next() = 0;
    end;

    local procedure ShowProcessingResultForPI(DataImportName: Text[50])
    var
        PurchHeader: Record "Purchase Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if PurchHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Invoices were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Invoices were created successfully./ Do you want to open a list of the created invoices?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Purchase Invoices", PurchHeader);
            end;
        end;
    end;

    local procedure ShowProcessingResultForPCM(DataImportName: Text[50])
    var
        PurchHeader: Record "Purchase Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Credit Memo");
        PurchHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if PurchHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some documents were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Documents were created successfully./ Do you want to open a list of the created documents?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Purchase Invoices", PurchHeader);
            end;
        end;
    end;

    local procedure ShowProcessingResultForPO(DataImportName: Text[50])
    var
        PurchHeader: Record "Purchase Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if PurchHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Orders were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Orders were created successfully. \Do you want to open a list of the created orders?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Purchase Order List", PurchHeader);
            end;
        end;
    end;

    local procedure ShowProcessingResultForSI(DataImportName: Text[50])
    var
        SalesHeader: Record "Sales Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if SalesHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Invoices were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Invoices were created successfully.\\ Do you want to open a list of the created invoices?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Sales Invoice List", SalesHeader);
            end;
        end;
    end;

    local procedure ShowProcessingResultForSCM(DataImportName: Text[50])
    var
        SalesHeader: Record "Sales Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if SalesHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some documents were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Documents were created successfully.\Do you want to open a list of the created documents?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Sales Invoice List", SalesHeader);
            end;
        end;
    end;

    local procedure ShowProcessingResultForSO(DataImportName: Text[50])
    var
        SalesHeader: Record "Sales Header";
        Staging: Record "RDBC_Base_DocImp_Staging";
        ConfirmMsg: Text;

    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("RDBC_Base_Data Import Name", DataImportName);

        if SalesHeader.IsEmpty() then begin
            Message('There are still errors.\Please review the staging table entries and resolve all errors before processing.');
            exit;
        end;

        Staging.SetRange("Data Import Name", DataImportName);
        Staging.SetFilter("Last Processing Error", '<>%1', '');  // any error for same Data Import Name                
        if not Staging.IsEmpty() then
            Message('Some Orders were created but there are still errors for some lines.\Please review the staging table entries and resolve all errors.')
        else begin
            ConfirmMsg := 'Orders were created successfully.\\ Do you want to open a list of the created orders?';
            if Confirm(ConfirmMsg, false) then begin
                Page.Run(Page::"Sales Order List", SalesHeader);
            end;
        end;
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

    #ENDREGION HELPER PROCEDURES
    // ****************************************************************************************




}

