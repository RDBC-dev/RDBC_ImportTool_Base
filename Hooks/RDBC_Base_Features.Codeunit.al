// Central switches for the two import areas. Both are NOT allowed by default:
// the customer extension decides what the customer may use, via OnAllowDocumentUpload /
// OnAllowJournalUpload. Without a customer extension nothing can be used, so uninstalling
// the customer extension never unlocks functionality.
// When an area is not allowed, its tiles are hidden and its pages and processing cannot be used.
codeunit 85162 "RDBC_Base_Features"
{
    var
        DocumentUploadNotAllowedErr: Label 'Document Import is not enabled for this company.';
        JournalUploadNotAllowedErr: Label 'Journal Import is not enabled for this company.';

    procedure IsDocumentUploadAllowed() Allow: Boolean
    var
        Events: Codeunit "RDBC_Base_Events";
    begin
        Allow := false;
        Events.OnAllowDocumentUpload(Allow);
    end;

    procedure IsJournalUploadAllowed() Allow: Boolean
    var
        Events: Codeunit "RDBC_Base_Events";
    begin
        Allow := false;
        Events.OnAllowJournalUpload(Allow);
    end;

    procedure CheckDocumentUploadAllowed()
    begin
        if not IsDocumentUploadAllowed() then
            Error(DocumentUploadNotAllowedErr);
    end;

    procedure CheckJournalUploadAllowed()
    begin
        if not IsJournalUploadAllowed() then
            Error(JournalUploadNotAllowedErr);
    end;
}
