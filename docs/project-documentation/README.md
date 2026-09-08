# Project screen documentation

Last reviewed: 2026-09-07

The walkthroughs in this folder pair original emulator screenshots with actions, observed results and illustrated Word documents. They describe the installed app on the capture date; they are not a claim that every automated test or backend transaction passed.

## Android SGAC 2.0 — 7 September 2026

- [Walkthrough overview and coverage](android-sgac2-2026-09-07/README.md)
- [Screenshot gallery](android-sgac2-2026-09-07/index.html) — open locally in a browser
- [All six Word documents](android-sgac2-2026-09-07/myica-flow-documents.zip)
- [Environment and synthetic records](android-sgac2-2026-09-07/environment.json)
- [Artifact validation](android-sgac2-2026-09-07/validation.json)
- [Flow inventory and suite reconciliation](android-sgac2-2026-09-07/flow-inventory.md)

The resumed walkthrough contains 200 documented screens from 207 original captures.
All 32 e-Service entry links, service search and the remaining Help/About destinations
were captured. The task records coverage boundaries separately from successful navigation.

| Category | Screens and Word document |
| --- | --- |
| Home, navigation, settings and help | [Open folder](android-sgac2-2026-09-07/01-home-and-navigation/README.md) |
| Resident profiles and SG Arrival Cards | [Open folder](android-sgac2-2026-09-07/02-resident-profiles-and-arrival-cards/README.md) |
| Foreign visitor profiles and SG Arrival Cards | [Open folder](android-sgac2-2026-09-07/03-foreign-visitor-profiles-and-arrival-cards/README.md) |
| QR codes at land checkpoints | [Open folder](android-sgac2-2026-09-07/04-qr-codes-at-land-checkpoints/README.md) |
| Cargo and convoy clearance | [Open folder](android-sgac2-2026-09-07/05-cargo-clearance/README.md) |
| Other e-Services | [Open folder](android-sgac2-2026-09-07/06-e-services/README.md) |

## Folder convention

Each dated run has an environment record and category folders. A category contains a Word document, a readable screen index, `coverage.json`, `manifest.json`, original PNGs in `screenshots/`, and matching Appium UI XML in `sources/`. The manifest records capture time, action, observation, outcome and the PNG's SHA-256 hash. Scroll positions, dialogs and validation states are captured when they add useful information.

Loading transitions and repeated views excluded from the finished documents remain in the dated run's `_capture-archive/`, with reasons. `curation.json` reconciles raw captures with the documented screen counts. No screenshot pixels are edited.

## Rebuild the documents

The checked-in screenshots and metadata are sufficient to rebuild the Word files and gallery without an emulator. The builder requires `python-docx` and Pillow in the chosen Python environment:

```sh
python -m pip install python-docx Pillow
python docs/project-documentation/_tools/build_documents.py
```

The builder verifies PNG hashes, decodes the images, parses their source XML, checks the DOCX archives and confirms that every indexed screenshot is embedded. It writes category indexes, the HTML gallery and `validation.json`. It is scoped to this dated capture run; update its `ROOT` when intentionally preparing another run.

`_tools/capture_android.py` is the capture helper used for this session. It expects `emulator-5554`, an Appium server on port 4727, and a walkthrough session file in `/private/tmp`. It supports explicit JSON commands for navigation and capture. It does not reset app data. Review its constants and command sequence before using it for a future capture session.
