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
