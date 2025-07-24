# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HueKnew is an iOS SwiftUI color learning game that helps users discover colors and learn their proper names. Built with Xcode for iOS 18.2+.

## Important Commands

**Note**: This is an Xcode project that cannot be built locally in Claude Code. All builds and tests run in GitHub Actions.

### Documentation
- **Update README TOC**: `npx doctoc README.md` (after modifying README.md)

### Version Control
- **Check status**: `git status` (run after changes to ensure clean state)
- **Commits**: Use concise messages, avoid amending existing commits

### Testing & Building
- Tests run automatically via GitHub Actions on push/PR
- Check `.github/workflows/ci.yml` for CI pipeline details
- No local builds possible - rely on GitHub Actions

## Architecture

### MVVM with @Observable
- **Models** (`HueKnew/Models/`): Business logic and data models using `@Observable`
  - `GameModel.swift`: Core game state and logic
  - `ColorDatabase.swift`: Parses TSV data and generates color pairs
  - `AudioManager.swift`: Sound effects management
  - `ImagineViewModel.swift`: Brainstorming mode logic

- **Views** (`HueKnew/Views/`): SwiftUI view files, kept small and modular
  - `ContentView.swift`: Main navigation hub
  - `GameView.swift`: Core gameplay interface
  - `LearningView.swift`: Side-by-side color comparison
  - `ChallengeView.swift`: Quiz interface
  - `CameraColorPickerView.swift`: AR camera color picker

- **Data** (`HueKnew/Data/`): Static data and database
  - `colors.tsv`: Color database (Hex, Category, Name, Description)
  - `environments.tsv`: Environment-color associations

### Key Files
- `HueKnewApp.swift`: App entry point with logging framework
- `Info.plist`: App configuration and permissions

## Working with Colors Data

The color database (`Data/colors.tsv`) has four tab-separated columns:
1. Hex (e.g., #E49B0F)
2. Category (e.g., Yellows)
3. Name (e.g., Gamboge)
4. Description (detailed color information)

When modifying:
- Keep header line intact
- Preserve TSV format (tabs, not spaces)
- Changes affect unit tests - update tests accordingly

## Testing Guidelines

Unit tests are in `HueKnewTests/`:
- `ColorDatabaseTests.swift`: Tests color loading and pair generation
- `GameModelTests.swift`: Tests game logic
- `MockColorDatabase.swift`: Mock for testing

## Development Notes

1. **No local Xcode operations** - Cannot run xcodebuild, simulators, or swiftlint locally
2. **Follow Swift conventions** - Standard Swift style, rules in `.swiftlint.yml` if present
3. **Preserve existing patterns** - Match code style when editing
4. **GitHub Actions validation** - PRs verified on macOS runners
5. **Asset updates** - Use Xcode on macOS for `Assets.xcassets` changes
6. **Project file edits** - Avoid manual `.xcodeproj` modifications

## CI/CD Pipeline

- **Branches**: main, testflight, codex/**
- **iOS target**: 18.2
- **Xcode version**: 16.2 (CI), latest-stable (CD)
- **TestFlight**: Automatic deployment on main/testflight push