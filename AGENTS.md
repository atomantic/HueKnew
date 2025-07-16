# AGENTS Instructions for HueKnew

Welcome to the **HueKnew** repository. This project is an iOS SwiftUI application built in Xcode. Because Codex runs on Linux, you will *not* be able to build or test the Xcode project locally. All builds and tests run in GitHub Actions (see `.github/workflows`).

## General Guidelines

- **No local builds/tests**: Do not attempt to run `xcodebuild` or launch simulators. Instead, rely on GitHub Actions (`ci.yml` and `cd.yml`).
- **Code style**: Follow Swift's standard style and the rules defined in `.swiftlint.yml`. We do not currently run SwiftLint in this environment, but the CI pipeline may enforce it in the future.
- **README updates**: If you modify `README.md`, regenerate its table of contents by running `npx doctoc README.md`.
- **Commit messages**: Use concise commit messages describing the change. Avoid amending existing commits.
- **Programmatic checks**: None can run locally. After each change, run `git status` to ensure a clean state before committing.
- **Pull requests**: GitHub Actions will verify that the project builds and tests on macOS. Review the action logs if your PR fails.

## Repository Structure

- `HueKnew/` – SwiftUI source code organized by feature.
- `HueKnewTests/` and `HueKnewUITests/` – Unit and UI tests run on macOS runners.
- `.github/workflows/` – CI/CD configuration for GitHub Actions.
- `Images/` – Static resources such as screenshots.

See subdirectory `AGENTS.md` files for more information about specific folders.
