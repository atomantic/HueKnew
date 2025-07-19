import Foundation
import SwiftUI // For ColorInfo, if it's a SwiftUI-specific struct

class ImagineViewModel: ObservableObject {
    @Published var currentEnvironment: String = ""
    @Published var inputText = ""
    @Published var enteredColors: [String] = []
    @Published var showResults = false
    @Published var selectedColorInfo: ColorInfo?
    @Published var showColorDetail = false
    @Published var isDone = false

    private let aliasMap: [String: String] = ["ochre": "Ocher (Ochre)"]
    internal let colorDatabase: ColorDatabaseProtocol

    init(colorDatabase: ColorDatabase = ColorDatabase.shared) {
        self.colorDatabase = colorDatabase
        if currentEnvironment.isEmpty {
            currentEnvironment = colorDatabase.availableEnvironments().randomElement() ?? "forest"
        }
    }

    var autocompleteSuggestions: [String] {
        guard !inputText.isEmpty else { return [] }
        let enteredSet = Set(enteredColors.map { $0.lowercased() })
        let lowerInput = inputText.lowercased()

        var suggestions: [String] = []

        // Alias matching (e.g. "ochre" -> "Ocher (Ochre)")
        if let alias = aliasMap.first(where: { lowerInput.hasPrefix($0.key) })?.value,
           !enteredSet.contains(alias.lowercased()) {
            suggestions.append(alias)
        }

        let allNames = colorDatabase.getAllColors().map { $0.name }
        let matches = allNames.filter {
            $0.lowercased().hasPrefix(lowerInput) && !enteredSet.contains($0.lowercased())
        }

        suggestions.append(contentsOf: matches)

        return Array(Set(suggestions)).sorted().prefix(5).map { $0 }
    }

    var environmentColors: [ColorInfo] {
        colorDatabase.colors(forEnvironment: currentEnvironment)
    }

    var suggestedColors: [ColorInfo] {
        let enteredSet = Set(enteredColors.map { $0.lowercased() })
        return environmentColors.filter { !enteredSet.contains($0.name.lowercased()) }
    }

    var unusualColors: [String] {
        let envSet = Set(environmentColors.map { $0.name.lowercased() })
        return enteredColors.filter { !envSet.contains($0.lowercased()) }
    }

    func addColor(_ text: String) {
        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        enteredColors.append(trimmed)
    }

    func handleDoneButton() {
        showResults = true
        isDone = true
        // Keyboard dismissal logic will remain in the View
    }

    func newEnvironment() {
        currentEnvironment = colorDatabase.availableEnvironments().randomElement() ?? "forest"
        enteredColors = []
        showResults = false
        isDone = false
    }
}