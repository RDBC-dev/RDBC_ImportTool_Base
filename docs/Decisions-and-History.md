# Decisions and history

Record of how the base/customer-app setup was created (2026-10-08) and why. Add new decisions at the end.

## Starting point

Three separate solutions with the same origin but drifted apart:

- **Master** (`RDBC_ImportTool_Master`): newest core (CSV import etc.), same app ID as CET.
- **CET** (`RDBC_ImportTool_CET`): Master + "Float" document type; only used for testing.
- **RWB** (`RDBC_ImportTool_RWB`, formerly `RDBC_ImportTool`): 61 commits, **in production**, own app ID,
  object/field IDs 55000+, code was in a `_rdbc_importtool/` subfolder (moved to top level).

First idea was a Git hierarchy (Master as `upstream` of CET/RWB, linked with an `-s ours` merge; that link
still exists in the legacy repos). It was replaced by the **base app + customer app** architecture in BC,
built as a completely **new solution** next to the old ones (old repos/folders stay untouched).

## Architecture decisions

| Decision | Reason |
|---|---|
| New base app with new app ID, prefix `RDBC_Base_`, range 85100–85199 | Old and new apps must be installable side by side for data migration (BC forbids duplicate object IDs/names) |
| Customer apps share range 85200–85299 | Customers never run in the same environment |
| Base code taken from Master (newest core); 31 of 46 objects were identical in all three | – |
| Customer logic only via events/hooks, never copied base code | One place for core fixes |
| Document/Journal Upload **off by default**, customer app switches on | Uninstalling a customer app must not unlock functionality |
| No separate "show tiles" hooks – tiles follow the Allow switches only | Simpler; one switch per area (tile hooks existed briefly and were removed) |
| Simple event-based switch, not `internalsVisibleTo` | Sufficient for the goal; anyone able to install extensions could bypass either way. Symbol download ("Get selected as dependencies") cannot be blocked in BC; source is protected via `resourceExposurePolicy` |
| Role center panel stays visible (empty) if nothing is allowed | Role center pages cannot have triggers (AL0378) |

## The 15 differing objects – decisions per item

| # | Topic | Decision |
|---|---|---|
| 1 | "Float" document type | CET app only (enumextension 85200; reuses base Purchase Invoice logic, vendor tax defaults, `NO TAX` → `NONTAXABLE`) |
| 2 | Additional Dimensions CUSTOMERGROUP / VENDORGROUP / PARENTCOMPANY (journal columns 21–23) | Not in base. RWB app only (CET had them by oversight → removed) |
| 3 | Journal Import tiles | Shown when Journal Upload is allowed |
| 4 | Role centers | Business Manager, Order Processor, Accountant, Purchasing Agent |
| 5 | Delete protection | RWB default: document staging blocks posted + processed lines; journal staging blocks posted lines |
| 6 | Credit memo "Apply to Document" | Optional (RWB logic); blank → posted unapplied |
| 7 | Duplicate External Doc. No. checks for PO, SO, SI, SCM | RWB logic in base (**see open item**) |
| 8 | Purchase Order: External Doc. No. goes to | **Vendor Order No.** (RWB logic) |
| 9 | Tax Liable/Tax Area must match vendor/customer when "Use Vendor's Tax Area Code" is on | Base (Master/CET logic) |
| 10 | Processing messages | Base default list (Master); customer apps can replace (CET, RWB have their own) |

Also taken into the base without decision: CSV import, journal group-skip bug fix, bank-account group-balance fix,
role center cue "blank when empty" fix (RWB), "Apply to Document" and "Applies-to Invoice No." as Text[100].

## Customer status

| Customer | Areas | Specifics | Status |
|---|---|---|---|
| CET | Document Import only | Float type, own messages | Base 1.0.0.1 + CET 1.0.0.1 tested OK in sandbox. Old CET test app was never in production → no migration; test data re-imported (Float value changed from 7 to 85200) |
| RWB | Document + Journal Import | Additional Dimensions, own messages | Apps built and compiled; **sandbox test with migration pending** |

## RWB migration (one-time)

`RDBC_ImportTool_Base-RWB-Migration` copies from the old RWB app (`20478970-…`):

- Field 55000 "Data Import Name" → 85100 and 55001 "Data Import Entry No." → 85101 on 22 tables
  (G/L, Cust./Vendor/Bank ledger entries, VAT entries, Gen. Journal Line, open and posted purchase/sales
  headers and lines, receipts, shipments).
- Staging tables 55000 → 85100 and 55011 → 85111 with the same Entry No.; Additional Dimensions 31/33/35 →
  RWB app fields 85200/85201/85202. Enums have identical ordinals.
- Checks old field/table names before touching anything; old data is never changed; safe to re-run.
- Not preserved: SystemCreatedAt/By of staging lines.

## Open items

- **RWB sandbox test** incl. migration (runtime-only risks: copying enum values via RecordRef, inserting staging
  lines with explicit AutoIncrement Entry No., permissions on posted tables).
- **Item 7:** RWB's duplicate check for Sales Invoices and Sales Credit Memos looks for open **Sales Orders**
  with the same External Doc. No. (not open invoices/credit memos). Taken over exactly as in RWB; confirm whether
  that is intended or a copy-paste slip.
- Pages of not-allowed areas still appear in BC search (they show "not enabled" when opened). Accepted.
- "Data Import Name" fields on standard pages stay visible regardless of the switches. Accepted.
