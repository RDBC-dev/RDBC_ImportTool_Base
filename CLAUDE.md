# RDBC Import Tool – Base

Business Central (AL) extension to bulk import purchase/sales documents and general journal lines
from Excel/CSV into staging tables, validate them and create documents/journal lines.
Publisher: **RD Business Consulting**. Platform/Application 27, runtime 16.

This repo is the **base app**. Customer-specific behaviour lives in separate **customer apps**
that depend on the base and plug in through events. Read these before changing anything:

- [docs/New-Customer.md](docs/New-Customer.md) – step-by-step procedure for adding a customer
- [docs/Decisions-and-History.md](docs/Decisions-and-History.md) – why things are the way they are, open items

## The apps

All folders are under `…/OneDrive-SharedLibraries-TIVOLO/TIVOLO Sprachdienstleistungen - DownloadSync/Visual Studio Code/`.
All repos are under `https://github.com/RDBC-dev/`.

| App (name in BC) | App ID | ID range | Folder | Repo |
|---|---|---|---|---|
| RDBC - ImportTool - Base | `fb89561f-4965-437c-abfd-14f49a9fdb29` | 85100–85199 | `_RD BC/RDBC - ImportTool - Base` | `RDBC_ImportTool_Base` |
| RDBC - ImportTool - CET | `b718eb50-251a-4fda-93c3-cf715bb20f19` | 85200–85299 | `_CET/RDBC ImportTool Base+CET` | `RDBC_ImportTool_Base-CET` |
| RDBC - ImportTool - RWB | `881c8fe0-54c8-4eac-bcbd-80084a340331` | 85200–85299 | `_RWB/RDBC_ImportTool_Base-RWB` | `RDBC_ImportTool_Base-RWB` |
| RDBC - ImportTool - RWB Migration (one-time) | `2a433082-915f-48a0-93d5-186c0361c346` | 85300–85349 | `_RWB/RDBC_ImportTool_Base-RWB-Migration` | `RDBC_ImportTool_Base-RWB-Migration` |

Legacy apps being replaced (do **not** change them; read-only reference):

| Legacy | App ID | Range / prefix | Folder | Repo |
|---|---|---|---|---|
| Old Master (= CET test version) | `5d1530d6-6ec8-47c0-b2af-fcfe343a856a` | 85000–85060, `_rdbc_` | `_RD BC/RDBC IMPORT TOOL` | `RDBC_ImportTool_Master` |
| Old CET (test only, never in production) | `5d1530d6-…` | 85000–85060, `_rdbc_` | `_CET/RDBC - CET Import Tool` | `RDBC_ImportTool_CET` |
| Old RWB (**in production**) | `20478970-8be9-4044-9cf0-7d5354ebebe6` | 55000+, `_rdbc_` | `_RWB/RDBC - RWB Import Tool` | `RDBC_ImportTool_RWB` |

## Rules

- **Nothing works without a customer app.** Document and Journal Upload are *off* in the base
  (`RDBC_Base_Features`). Each customer app switches on what the customer may use by subscribing to
  `OnAllowDocumentUpload` / `OnAllowJournalUpload` and setting `Allow := true`. Uninstalling a customer
  app must never unlock functionality. "Not allowed" hides the role center tiles and blocks upload pages,
  staging pages, import and processing.
- **Never copy base code into a customer app.** Extend through the hooks below. If a hook is missing, add a
  new `IntegrationEvent` (or a public procedure) to the base instead of copying.
- **ID ranges:** base 85100–85199; every customer app 85200–85299 (customers never share an environment);
  one-time migration apps 85300–85349. Enum extension values must also be in the app's range
  (e.g. CET "Float" = 85200).
- **Prefixes:** base `RDBC_Base_`, customer apps `RDBC_<CUSTOMER>_` (e.g. `RDBC_CET_`, `RDBC_RWB_`),
  migration `RDBC_MIG_`. Object and field names are max. **30 characters**.
- New prefix/IDs were chosen so the new apps can be installed **next to** a legacy app during a data
  migration (BC forbids duplicate object IDs and names across installed apps).
- `resourceExposurePolicy`: no debugging, no source download, no source in symbols – keep it that way.
- Role center pages/page extensions **cannot have triggers** (AL0378) – visibility logic belongs in the cue
  pages (`RDBC_Base_RC.Cue.al`).
- Several `.al` files use **CRLF** line endings; preserve the existing line endings when editing.
- Pages that customer apps extend expose state as `protected var` (e.g. `IsEditable` on the journal staging page).

## Hooks for customer apps (`Hooks/`)

`RDBC_Base_Events` (codeunit 85160) – subscribe to these:

| Event | Use |
|---|---|
| `OnAllowDocumentUpload(var Allow)` / `OnAllowJournalUpload(var Allow)` | **Mandatory**: which import areas the customer may use |
| `OnAllowDocumentCsvUpload(var Allow)` / `OnAllowJournalCsvUpload(var Allow)` | Show "Import CSV File" in an allowed area (off by default; Excel upload is always available) |
| `OnValidateCustomDocumentType` / `OnProcessCustomDocumentType` / `OnShowProcessingResultCustomDocumentType` | Own Document Import Types added via `enumextension` on `RDBC_Base_DocImpType` (see CET "Float") |
| `OnAfterValidateDocumentLine` | Extra checks on document staging lines |
| `OnAfterReadJournalExcelRow` / `OnAfterReadJournalCsvRow` | Read extra journal columns (e.g. RWB Additional Dimensions, columns 21–23) |
| `OnAfterValidateJournalLine` | Extra checks on journal staging lines |
| `OnAddJournalDimensions` | Add extra dimensions to created journal lines |
| `OnGetDocumentProgressMessages` / `OnGetJournalProgressMessages` | Customer-specific "processing…" texts |
| `OnGetProductName(var ProductName)` | Name in front of the page captions (default `RDBC`, e.g. "RDBC Document Upload"; `''` = no prefix) |

Page captions are compiled **without** a prefix ("Document Upload"); upload, staging and role center cue pages
add the product name at runtime in `OnOpenPage` via `RDBC_Base_Features.GetCaption(CurrPage.Caption)`.
BC search and table captions always show the compiled (neutral) caption.

Public helpers: `RDBC_Base_ImportHelper` (85161: `AddError`, `ValidateDimensionValue`, `SetDimension`),
`RDBC_Base_Features` (85162: `IsDocumentUploadAllowed`, `IsJournalUploadAllowed`,
`IsDocumentCsvUploadAllowed`, `IsJournalCsvUploadAllowed`, `Check…`),
`RDBC_Base_DocImpValidationMgt.ValidateLineAs(Type, Staging, ErrorText)` (validate a custom type like a
standard one), and the processors, e.g. `RDBC_Base_PI_Processor.Process` / `ShowProcessingResultForPI`.

## Building

The AL compiler can run from the command line on this Mac (no Windows needed):

```sh
DN="$HOME/Library/Application Support/Code/User/globalStorage/ms-dotnettools.vscode-dotnet-runtime/.dotnet/10.0.12~arm64~aspnetcore/dotnet"
ALC=$(ls -d ~/.vscode/extensions/ms-dynamics-smb.al-*/bin/alc.dll | tail -1)
"$DN" "$ALC" /project:"<app folder>" /packagecachepath:"<app folder>/.alpackages" /out:"<output>.app"
```

- `.alpackages` is not in Git. Microsoft symbols come from "AL: Download Symbols" (or copy them from another
  app folder). A customer app also needs the **base .app** in its `.alpackages`: compile the base and copy
  the resulting `RD Business Consulting_RDBC - ImportTool - Base_<version>.app` there.
- After changing the base, recompile **every** customer app against the new base before pushing.
- Target: 0 errors, 0 warnings.

## Versions and deployment

- Bump `version` in `app.json` for every deployment (base and customer app separately) and commit it.
- Customer apps reference the base with a minimum version (`1.0.0.0` = this version or newer).
- Install order: Base → customer app (→ migration app, only when replacing a legacy app).
- Status (2026-10-08): Base 1.0.0.1 + CET 1.0.0.1 tested OK in the CET sandbox. RWB sandbox test pending.
