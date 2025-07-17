# Data Directory

`colors.tsv` contains the color database used by `ColorDatabase.swift`.

- The TSV file has four columns in this order: `Hex`, `Category`, `Name`, `Description`.
- Keep the header line intact.
- Fields may contain spaces; descriptions may include commas. Escape tabs or quotes with standard TSV quoting.
- The Swift code expects this file to be bundled with the app. Changes to the dataset may affect unit tests.

`ColorDatabase.swift` parses this TSV and generates color pairs. When editing this file, preserve existing functions and pay attention to the mapping logic.
