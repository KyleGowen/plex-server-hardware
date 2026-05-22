# Build Component Manuals

Reference PDFs collected for the Plex server rebuild.

| Component | Local PDF | Source / note |
|---|---|---|
| MSI PRO Z790-A WiFi II motherboard | `msi-pro-z790-a-wifi-ii-user-guide.pdf` | Official MSI user guide for PRO Z790-A MAX WIFI / PRO Z790-A WIFI II, downloaded from `https://download.msi.com/archive/mnu_exe/mb/PROZ790-AMAXWIFI_EN.pdf` |
| MSI PRO Z790-A WiFi II quick start | `msi-pro-z790-a-wifi-ii-quick-start.pdf` | Quick Start section extracted from the official MSI user guide, pages 4-15; covers CPU, DDR5, front-panel header, motherboard mounting, power connectors, SATA, GPU, peripherals, and first power-on |
| MSI Intel 700-series BIOS | `msi-intel-700-series-bios-user-guide.pdf` | MSI BIOS guide linked from motherboard manual |
| Intel Core i5-14500 | `intel-core-14th-gen-desktop-processor-product-brief.pdf` | Intel 14th Gen desktop processor product brief |
| Lexar THOR DDR5 memory | `lexar-thor-rgb-ddr5-desktop-memory-setup-sheet.pdf` | Lexar THOR RGB DDR5 setup sheet; closest official THOR DDR5 setup PDF found |
| Noctua NH-U9S chromax.black | `noctua-nh-u9s-chromax-black-installation-manual.pdf` | Official Noctua English installation manual, downloaded from `https://cdn.noctua.at/media/noctua_nh_u9s_chromax.black_manual_en_web.pdf?download=true` |
| Corsair RM750e PSU | `corsair-rm750e-rme-series-power-supply-manual.pdf` | Corsair RMe Series manual |
| SilverStone GD07 case | `silverstone-gd07-manual.pdf` | GD07 manual PDF mirror; SilverStone product page was not directly fetchable by command-line download |
| GIGABYTE GeForce RTX 3050 WINDFORCE OC 6G GPU | `gigabyte-geforce-rtx-3050-windforce-oc-6g-gv-n3050wf2oc-6gd-quick-guide.pdf` | Official GIGABYTE graphics card quick guide linked from the GV-N3050WF2OC-6GD support/manual page |
| Thermaltake TT-1225 / A1225L12S case fan | No local PDF found | OEM / case-bundled fan; documented in `case-fan-source-notes.md` from matching parts/spec listings |
| SilverStone CC12025L12S case fan | No local PDF found | SilverStone-branded OEM fan; documented in `case-fan-source-notes.md` with CC12025 fan-family datasheet link |

## Notes

- Do not use these manuals as permission to rewire storage destructively. Preserve the OS SSD and media HDDs.
- MSI appears to publish the board's quick installation material as the Quick Start section inside the full user guide rather than as a separate standalone download.
- For the RAM, replace the THOR RGB setup sheet if the exact THOR Z non-RGB product PDF becomes available.
- The two extra case fans appear to be OEM / case-bundled fans rather than retail parts with standalone manuals. See `case-fan-source-notes.md`.
