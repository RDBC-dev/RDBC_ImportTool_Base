# Adding a new customer

Every customer gets its **own customer app** that depends on the base app. Without a customer app the
import tool does nothing (both import areas are off by default). Use the CET app
(`_CET/RDBC ImportTool Base+CET`) as the simplest example and the RWB app (`_RWB/RDBC_ImportTool_Base-RWB`)
as the example with extra journal fields.

## 1. Clarify requirements

Ask / decide:

1. **Which areas may the customer use?** Document Import, Journal Import, or both.
2. **Special document types?** (e.g. CET "Float" = Purchase Invoice with vendor tax defaults)
3. **Extra fields / Excel columns / dimensions?** (e.g. RWB Additional Dimensions in journal columns 21–23)
4. **Extra validation rules?**
5. **Own processing messages?** (otherwise the base default list is shown)
6. **Does the customer already have an old Import Tool installed with data to keep?** → see step 7.

For every requirement decide: **everyone (base)** or **this customer only (customer app)**.
Rule of thumb: generally useful improvements and bug fixes go into the base; anything tied to one customer's
setup (fixed dimension codes, tax rules, special types) goes into the customer app.
If the customer app needs something the base cannot do yet, add a hook to the base first
(new `IntegrationEvent` in `Hooks/RDBC_Base_Events.Codeunit.al`), bump the base version, then build the app.

## 2. Create folder and repository

- Create an **empty** GitHub repo under `RDBC-dev`, naming pattern `RDBC_ImportTool_Base-<CUSTOMER>`.
- Create the folder under the customer's directory, e.g. `…/Visual Studio Code/_<CUSTOMER>/RDBC_ImportTool_Base-<CUSTOMER>`.
- Copy `.gitignore`, `.vscode/settings.json` and `Resources/RDBCImportTool.png` from the base.
- Put the Microsoft symbols and the current **base .app** into `.alpackages/` (not committed).

## 3. app.json

Use a **new GUID** (`uuidgen | tr A-Z a-z`). Template:

```json
{
  "id": "<new guid>",
  "name": "RDBC - ImportTool - <CUSTOMER>",
  "publisher": "RD Business Consulting",
  "version": "1.0.0.0",
  "description": "<CUSTOMER>-specific extension of the RDBC Import Tool: …",
  "logo": "Resources/RDBCImportTool.png",
  "dependencies": [
    {
      "id": "fb89561f-4965-437c-abfd-14f49a9fdb29",
      "name": "RDBC - ImportTool - Base",
      "publisher": "RD Business Consulting",
      "version": "<current base version>"
    }
  ],
  "platform": "27.0.0.0",
  "application": "27.0.0.0",
  "idRanges": [ { "from": 85200, "to": 85299 } ],
  "resourceExposurePolicy": {
    "allowDebugging": false,
    "allowDownloadingSource": false,
    "includeSourceInSymbolFile": false
  },
  "runtime": "16.0",
  "features": [ "NoImplicitWith" ],
  "resourceFolders": [ "Resources" ]
}
```

## 4. Mandatory: allowed import areas

`RDBC_<CUSTOMER>_Customization.Codeunit.al` (codeunit in 85200–85299):

```al
// <CUSTOMER>-specific settings: allowed import areas and processing messages.
codeunit 852xx "RDBC_<CUSTOMER>_Customization"
{
    // What <CUSTOMER> may use. The base allows nothing by default.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RDBC_Base_Events", 'OnAllowDocumentUpload', '', false, false)]
    local procedure AllowDocumentUpload(var Allow: Boolean)
    begin
        Allow := true;
    end;

    // Only if the customer may use Journal Import:
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RDBC_Base_Events", 'OnAllowJournalUpload', '', false, false)]
    local procedure AllowJournalUpload(var Allow: Boolean)
    begin
        Allow := true;
    end;

    // Only if the customer may upload CSV files (Excel is always available in an allowed area).
    // Without these subscribers the "Import CSV File" action is hidden.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RDBC_Base_Events", 'OnAllowDocumentCsvUpload', '', false, false)]
    local procedure AllowDocumentCsvUpload(var Allow: Boolean)
    begin
        Allow := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RDBC_Base_Events", 'OnAllowJournalCsvUpload', '', false, false)]
    local procedure AllowJournalCsvUpload(var Allow: Boolean)
    begin
        Allow := true;
    end;
}
```

## 5. Optional extensions (pick what is needed)

| Need | How | Example |
|---|---|---|
| Own processing messages | Subscribe `OnGetDocumentProgressMessages` / `OnGetJournalProgressMessages`, fill `Messages`, `IsHandled := true` | CET, RWB `…_Customization` |
| Own document type | `enumextension` on `RDBC_Base_DocImpType` (value ID in 85200–85299) + subscribers `OnValidateCustomDocumentType`, `OnProcessCustomDocumentType`, `OnShowProcessingResultCustomDocumentType`. Reuse base logic via `ValidateLineAs(...)` and the `RDBC_Base_*_Processor` codeunits | CET `RDBC_CET_Float.Codeunit.al` |
| Extra journal fields/columns/dimensions | `tableextension` + `pageextension` on `RDBC_Base_JnlImp_Staging` (page fields use `Editable = IsEditable`), subscribers `OnAfterReadJournalExcelRow`, `OnAfterReadJournalCsvRow`, `OnAfterValidateJournalLine`, `OnAddJournalDimensions`; use `RDBC_Base_ImportHelper` | RWB `JournalImport/` |
| Extra checks on document lines | `OnAfterValidateDocumentLine` + `RDBC_Base_ImportHelper.AddError` | – |

Add every new codeunit to a `permissionsetextension 852xx … extends "RDBC_Base ImportTool"`
so users only need the base permission set.

Also add a short `README.md` (what the app contains, which file).

## 6. Build, commit, push

- Compile the app (command in `CLAUDE.md`) → 0 errors, 0 warnings.
- `git init -b main`, commit, add the remote, push.

## 7. Customer already has an old Import Tool with data (migration)

Only if data must be preserved (pattern: `_RWB/RDBC_ImportTool_Base-RWB-Migration`):

- Build a separate one-time migration app (range 85300–85349, prefix `RDBC_MIG_`) depending on base + customer app.
- It reads the old app **by table/field number** (`RecordRef`), checks the old field/table **names** before
  touching anything, copies into the new fields/tables, keeps staging `Entry No.`s, never changes old data,
  and is safe to run more than once. A page with **Check** and **Run Migration** shows old vs. new counts.
- Old and new apps must be installable side by side (that is why the new apps use other IDs and names).
- Not preserved: `SystemCreatedAt/By` of copied records.
- If the old app was only used for testing (like CET), skip the migration and re-import test data.

## 8. Test in a sandbox, then production

1. Install **Base → customer app** (→ migration app next to the old app, if any).
2. Assign permission set **RDBC_Base ImportTool**.
3. Check the role center: only the allowed areas show tiles; not-allowed pages show "…is not enabled for this company."
4. Upload a sample document file (download it from the upload page), validate, process.
5. Journal (if allowed): upload, validate, process, check dimensions on the journal lines.
6. Customer specifics (own types, fields).
7. Migration (if any): Run Migration → all lines "OK"; spot-check Data Import Name on G/L entries / posted documents;
   run once more right before switching; uninstall the old app **without deleting its data**; uninstall the migration app.
8. Bump versions, commit and push what was deployed.
