# AGENTS Instructions for HueKnew

Welcome to the **HueKnew** repository. This project is an iOS SwiftUI application built in Xcode. Because Codex runs on Linux, you will *not* be able to build or test the Xcode project locally. All builds and tests run in GitHub Actions (see `.github/workflows`).

## General Guidelines

- **No local builds/tests**: Do not attempt to run `xcodebuild` or launch simulators. Instead, rely on GitHub Actions (`ci.yml` and `cd.yml`).
- **No local linting**: Do not attempt to run `swiftlint` locally. The CI pipeline may enforce it in the future.
- **Code style**: Follow Swift's standard style and the rules defined in `.swiftlint.yml`.
- **README updates**: If you modify `README.md`, regenerate its table of contents by running `npx doctoc README.md`.
- **Commit messages**: Use concise commit messages describing the change. Avoid amending existing commits.
- **Programmatic checks**: None can run locally. After each change, run `git status` to ensure a clean state before committing.
- **Pull requests**: GitHub Actions will verify that the project builds and tests on macOS. Review the action logs if your PR fails.

## Repository Structure

- `HueKnew/` – Contains the main application source code.
    - `Models/` – Business logic and data models (uses MVVM with `@Observable`).
    - `Views/` – SwiftUI view files. Keep view structs small and modular.
    - `Data/` – Static data files and database helpers.
        - `colors.tsv` contains the color database used by `ColorDatabase.swift`.
            - The TSV file has four columns in this order: `Hex`, `Category`, `Name`, `Description`.
            - Keep the header line intact.
            - Fields may contain spaces; descriptions may include commas. Escape tabs or quotes with standard TSV quoting.
            - The Swift code expects this file to be bundled with the app. Changes to the dataset may affect unit tests.
        - `ColorDatabase.swift` parses this TSV and generates color pairs. When editing this file, preserve existing functions and pay attention to the mapping logic.
    - `Assets.xcassets` – Xcode asset catalog.
- `HueKnewTests/` – Unit tests for the application logic.
- `HueKnewUITests/` – UI tests for the application's user interface.
- `.github/workflows/` – CI/CD configuration for GitHub Actions.
- `Images/` – Static resources such as screenshots.

## Adding Features

1. Place new model objects in `HueKnew/Models/`.
2. Place new view code in `HueKnew/Views/`.
3. If you add resources (e.g., images), update `HueKnew/Assets.xcassets` via Xcode on macOS.
4. Update `HueKnew.xcodeproj` only when necessary. Avoid hand-editing the project file.

Unit tests live in `HueKnewTests/` and run in GitHub Actions.
