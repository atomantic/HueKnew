# HueKnew Directory

This folder contains the Swift source for the app.

## Layout

- `Models/` – Business logic and data models (uses MVVM with `@Observable`).
- `Views/` – SwiftUI view files. Keep view structs small and modular.
- `Data/` – Static data files and database helpers.
- `Assets.xcassets` – Xcode asset catalog.

## Adding Features

1. Place new model objects in `Models/`.
2. Place new view code in `Views/`.
3. If you add resources (e.g., images), update `Assets.xcassets` via Xcode on macOS.
4. Update `HueKnew.xcodeproj` only when necessary. Avoid hand-editing the project file.

Unit tests live in `../HueKnewTests` and run in GitHub Actions.

# Data Directory

`colors.tsv` contains the color database used by `ColorDatabase.swift`.

- The TSV file has four columns in this order: `Hex`, `Category`, `Name`, `Description`.
- Keep the header line intact.
- Fields may contain spaces; descriptions may include commas. Escape tabs or quotes with standard TSV quoting.
- The Swift code expects this file to be bundled with the app. Changes to the dataset may affect unit tests.

`ColorDatabase.swift` parses this TSV and generates color pairs. When editing this file, preserve existing functions and pay attention to the mapping logic.