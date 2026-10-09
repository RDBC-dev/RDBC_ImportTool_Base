// Central switches for the two import areas. Both are allowed by default;
// a customer extension can switch an area off via OnAllowDocumentUpload / OnAllowJournalUpload.
// When an area is switched off, its tiles are hidden and its pages and processing cannot be used.
codeunit 85162 "RDBC_Base_Features"
{
    var
        DocumentUploadNotAllowedErr: Label 'Document Import is not enabled for this company.';
        JournalUploadNotAllowedErr: Label 'Journal Import is not enabled for this company.';

    procedure IsDocumentUploadAllowed() Allow: Boolean
    var
        Events: Codeunit "RDBC_Base_Events";
    begin
        Allow := true;
        Events.OnAllowDocumentUpload(Allow);
    end;

    procedure IsJournalUploadAllowed() Allow: Boolean
    var
        Events: Codeunit "RDBC_Base_Events";
    begin
        Allow := true;
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
