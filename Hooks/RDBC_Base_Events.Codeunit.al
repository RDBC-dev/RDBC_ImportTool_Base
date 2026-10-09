// All hooks that customer-specific extensions can subscribe to.
// The base app raises these events; it never needs to know which customer app listens.
codeunit 85160 "RDBC_Base_Events"
{
    #REGION DOCUMENT IMPORT

    // Raised for every staging line after the base validation ran.
    // Add customer-specific checks with RDBC_Base_ImportHelper.AddError(ErrorText, '...').
    [IntegrationEvent(false, false)]
    procedure OnAfterValidateDocumentLine(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024])
    begin
    end;

    // Raised for Document Import Types the base does not know (added via enumextension).
    // Set IsHandled := true when the subscriber validated the line.
    [IntegrationEvent(false, false)]
    procedure OnValidateCustomDocumentType(var Staging: Record "RDBC_Base_DocImp_Staging"; var ErrorText: Text[1024]; var IsHandled: Boolean)
    begin
    end;

    // Raised for Document Import Types the base does not know (added via enumextension).
    // Create the document, set DocumentNo, Success and IsHandled := true.
    // When Success is false, the base logs GetLastErrorText() on the staging lines.
    [IntegrationEvent(false, false)]
    procedure OnProcessCustomDocumentType(var GroupRec: Record "RDBC_Base_DocImp_Staging"; var Staging: Record "RDBC_Base_DocImp_Staging"; var DocumentNo: Code[20]; var Success: Boolean; var IsHandled: Boolean)
    begin
    end;

    // Raised after processing when the batch belongs to a Document Import Type the base does not know.
    [IntegrationEvent(false, false)]
    procedure OnShowProcessingResultCustomDocumentType(DocumentImportType: Enum "RDBC_Base_DocImpType"; DataImportName: Text[50])
    begin
    end;

    #ENDREGION DOCUMENT IMPORT

    #REGION JOURNAL IMPORT

    // Raised for every Excel row after the base columns were read, before the staging line is inserted.
    [IntegrationEvent(false, false)]
    procedure OnAfterReadJournalExcelRow(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer)
    begin
    end;

    // Raised for every CSV row after the base columns were read, before the staging line is inserted.
    [IntegrationEvent(false, false)]
    procedure OnAfterReadJournalCsvRow(var Staging: Record "RDBC_Base_JnlImp_Staging"; Columns: List of [Text])
    begin
    end;

    // Raised for every staging line after the base validation ran.
    [IntegrationEvent(false, false)]
    procedure OnAfterValidateJournalLine(var Staging: Record "RDBC_Base_JnlImp_Staging"; var ErrorText: Text[1024])
    begin
    end;

    // Raised while the dimensions of a journal line are built.
    // Add dimensions with RDBC_Base_ImportHelper.SetDimension(TempDimSetEntry, DimCode, DimValueCode)
    // and set HasDimensions := true when the line carries customer-specific dimensions.
    [IntegrationEvent(false, false)]
    procedure OnAddJournalDimensions(GroupRec: Record "RDBC_Base_JnlImp_Staging"; var TempDimSetEntry: Record "Dimension Set Entry" temporary; var HasDimensions: Boolean)
    begin
    end;

    #ENDREGION JOURNAL IMPORT

    #REGION FEATURES

    // "Allow Document Upload": set Allow := false to switch off Document Import completely
    // (role center tiles, upload page, staging pages and processing).
    [IntegrationEvent(false, false)]
    procedure OnAllowDocumentUpload(var Allow: Boolean)
    begin
    end;

    // "Allow Journal Upload": set Allow := false to switch off Journal Import completely
    // (role center tiles, upload page, staging page and processing).
    [IntegrationEvent(false, false)]
    procedure OnAllowJournalUpload(var Allow: Boolean)
    begin
    end;

    #ENDREGION FEATURES

    #REGION USER INTERFACE

    // Replace or extend the texts shown while documents are processed.
    // Set IsHandled := true to use only the subscriber's list.
    [IntegrationEvent(false, false)]
    procedure OnGetDocumentProgressMessages(var Messages: List of [Text]; var IsHandled: Boolean)
    begin
    end;

    // Replace or extend the texts shown while journal lines are processed.
    // Set IsHandled := true to use only the subscriber's list.
    [IntegrationEvent(false, false)]
    procedure OnGetJournalProgressMessages(var Messages: List of [Text]; var IsHandled: Boolean)
    begin
    end;

    #ENDREGION USER INTERFACE
}
