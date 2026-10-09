# RDBC - ImportTool - Base

Base extension of the RDBC Import Tool for Business Central.

| App | Repository | Object ID range |
|---|---|---|
| RDBC - ImportTool - Base | RDBC_ImportTool_Base | 85100–85199 |
| Customer extension (CET or RWB) | one repository per customer | 85200–85299 |

- Functionality that every customer gets lives here.
- Customer-specific functionality lives in a separate extension that depends on this app
  and plugs in through events, interfaces and extensible enums.
- CET and RWB never run in the same environment, so their extensions share one ID range.
