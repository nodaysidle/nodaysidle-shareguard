# codemap.md

```
nodaysidle-shareguard/
├── Package.swift                SwiftPM manifest, macOS 14+, Swift 6
├── README.md
├── AGENTS.md
├── PRD.md
├── ARD.md
├── TRD.md
├── TASKS.md
├── Scripts/
│   └── package_app.sh           Builds release .app, writes Info.plist/PkgInfo, ad-hoc signs
├── Resources/                   Optional assets copied into bundle
├── Sources/ShareGuard/
│   ├── ShareGuardApp.swift      App entry point, WindowGroup
│   ├── Models/
│   │   └── Finding.swift        Severity, DetectorType, Finding, ScanSummary, ScanResult
│   ├── Utilities/
│   │   ├── Constants.swift      AppColors, SeverityColor
│   │   ├── Redaction.swift      Secret redaction helpers
│   │   └── Extensions.swift     URL helpers, line number
│   ├── Detector/
│   │   ├── DetectionEngine.swift Orchestrates all detectors
│   │   └── Detector.swift       Detector protocol + implementations
│   ├── Scanner/
│   │   └── FileEnumerator.swift Recursive enumeration with ignore rules
│   └── Views/
│       ├── ContentView.swift    Main window
│       ├── ScanViewModel.swift  State + scan orchestration
│       ├── DropZoneView.swift   Drag/drop target
│       ├── SummaryCard.swift    Scan summary
│       ├── FindingsList.swift   Findings list UI
│       └── ErrorsSection.swift  Errors list UI
└── Tests/ShareGuardTests/
    ├── RedactionTests.swift
    ├── DetectorTests.swift
    └── FileEnumeratorTests.swift
```
