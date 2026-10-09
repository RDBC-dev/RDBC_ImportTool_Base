# RDBC - ImportTool - Base

Base extension of the RDBC Import Tool for Business Central.

| App | Repository | Object ID range |
|---|---|---|
| RDBC - ImportTool - Base | RDBC_ImportTool_Base | 85100–85199 |
| Customer extension | one repository per customer | 85200–85299 |

- Functionality that every customer gets lives here.
- Customer-specific functionality lives in a separate extension that depends on this app
  and plugs in through events, interfaces and extensible enums.
- CET and RWB never run in the same environment, so their extensions share one ID range.
- **Nothing is available without a customer extension.** Document Import and Journal Import are
  off by default; each customer extension switches on what the customer may use
  (`RDBC_Base_Events.OnAllowDocumentUpload` / `OnAllowJournalUpload`, set `Allow := true`).
  Uninstalling the customer extension therefore switches the import functionality off.

## Documentation

- [docs/New-Customer.md](docs/New-Customer.md) – how to add a new customer
- [docs/Decisions-and-History.md](docs/Decisions-and-History.md) – decisions, customer status, open items
- [CLAUDE.md](CLAUDE.md) – overview of all apps, IDs, rules, hooks and build commands
