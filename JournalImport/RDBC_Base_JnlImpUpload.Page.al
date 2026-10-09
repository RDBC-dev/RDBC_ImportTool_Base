page 85110 "RDBC_Base_JnlImpExcel"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'RDBC Journal Upload';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(DataImportName; DataImportName)
                {
                    Caption = 'Data Import Name';
                    ApplicationArea = All;
                }
            }

            group(Instructions)
            {
                Caption = 'Instructions';

                field(InstructionText; InstructionText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                }
                field(JournalTypes; JournalTypeText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                }
            }

            part(ImportCues; "RDBC_Base_JnlImp_Cues")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportExcel)
            {
                Caption = 'Import Excel File';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    InStr: InStream;
                    FileName: Text;
                    ImportMgt: Codeunit "RDBC_Base_JnlImpExcelMgt";
                begin
                    if DataImportName = '' then
                        Error('Please enter Data Import Name below.');

                    UploadIntoStream(
                        'Select Excel File',
                        '',
                        'Excel file (*.xlsx)|*.xlsx',
                        FileName,
                        InStr);

                    if FileName = '' then
                        exit;

                    ImportMgt.ImportExcelToStaging(InStr, DataImportName);
                end;
            }

            action(ImportCsv)
            {
                Caption = 'Import CSV File';
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    InStr: InStream;
                    FileName: Text;
                    ImportMgt: Codeunit "RDBC_Base_JnlImpExcelMgt";
                begin
                    if DataImportName = '' then
                        Error('Please enter Data Import Name below.');

                    UploadIntoStream(
                        'Select CSV File',
                        '',
                        'CSV file (*.csv)|*.csv',
                        FileName,
                        InStr);

                    if FileName = '' then
                        exit;

                    ImportMgt.ImportCsvToStaging(InStr, DataImportName);
                end;
            }

            action(DownloadSample)
            {
                Caption = 'Download Sample Excel';
                Image = Download;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    DownloadSampleExcel();
                end;
            }

        }
    }

    var
        DataImportName: Text[50];
        InstructionText: TextConst ENU =
        '1. Enter a Name for you Import. It will be added to Journal Lines.\2. Click "Import Excel File" or "Import CSV File".\3. Choose your Excel file (.xlsx, worksheet must be named "IMPORT") or your CSV file (.csv, any name, comma or semicolon separated).\4. The data from your file will be imported into a table and shown.';
        JournalTypeText: TextConst ENU = 'Supported Journal Import Types: General, Sales Payment and Purchase Payment.\For Sales Payment lines, use Type = Customer; for Purchase Payment lines, use Type = Vendor; both must fill Applies-to Invoice No. in column Z.\Bal. Account No. can be left blank for these lines - use a separate line with Type = Bank Account (and no Bal. Account) in the same Document No. to fund/balance the payment.';
        SelectedImportName: Code[50];


    local procedure DownloadSampleExcel()
    var
        InStr: InStream;
        FileName: Text;
        Found: Boolean;
    begin
        // Path must match app.json "resources" path
        NavApp.GetResource('RDBC_JnlImport_Sample_File.xlsx', InStr);
        FileName := 'RDBC_JnlImport_Sample_File.xlsx';

        // DownloadFromStream signature: (InStream, DialogTitle, InitialDir, Filter, DefaultFileName)
        // On web, filter is ignored; we keep it for consistency.
        DownloadFromStream(
            InStr,
            'Download Sample Excel File',
            '',
            'Excel File (*.xlsx)|*.xlsx',
            FileName);
    end;


    trigger OnOpenPage()
    var
        Features: Codeunit "RDBC_Base_Features";
    begin
        Features.CheckJournalUploadAllowed();
    end;
}