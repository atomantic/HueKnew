import SwiftUI

struct ImagineView: View {
    @State private var currentEnvironment: String = ""
    @State private var inputText = ""
    @State private var enteredColors: [String] = []
    @State private var showResults = false
    @State private var selectedColorInfo: ColorInfo?
    @State private var showColorDetail = false

    private let aliasMap: [String: String] = ["ochre": "Ocher (Ochre)"]

    private let colorDatabase = ColorDatabase.shared

    private var autocompleteSuggestions: [String] {
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

    private var environmentColors: [ColorInfo] {
        colorDatabase.colors(forEnvironment: currentEnvironment)
    }

    private var suggestedColors: [ColorInfo] {
        let enteredSet = Set(enteredColors.map { $0.lowercased() })
        return environmentColors.filter { !enteredSet.contains($0.name.lowercased()) }
    }

    private var unusualColors: [String] {
        let envSet = Set(environmentColors.map { $0.name.lowercased() })
        return enteredColors.filter { !envSet.contains($0.lowercased()) }
    }

    private var promptView: some View {
        VStack(spacing: 2) {
            Text("Imagine colors in this scene:")
            Text(currentEnvironment)
                .font(.title3)
                .bold()
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    private func addColor(_ text: String) {
        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        enteredColors.append(trimmed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Imagine")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

            promptView
            TextField("Enter color", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    addColor(inputText)
                    inputText = ""
                }
                .onChange(of: inputText) { newValue in
                    if newValue.contains(",") {
                        let parts = newValue.split(separator: ",")
                        parts.dropLast().forEach { part in addColor(String(part)) }
                        inputText = parts.last.map(String.init) ?? ""
                    }
                }

            if !enteredColors.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(enteredColors, id: \.self) { name in
                        ColorPill(name: name, info: colorDatabase.color(named: name))
                    }
                }
            }

            if !autocompleteSuggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(autocompleteSuggestions, id: \.self) { suggestion in
                            Button(action: {
                                enteredColors.append(suggestion)
                                inputText = ""
                            }) {
                                Text(suggestion)
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
                .background(Color(.systemGray6))
            }

            Button("Done") {
                showResults = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            if showResults {
                if suggestedColors.isEmpty {
                    Text("You've named all the colors we could think of for this environment! Try another one.")
                        .font(.footnote)
                        .foregroundColor(.init(red: 0.0, green: 0.5, blue: 0.0))
                    Button("New Environment") {
                        currentEnvironment = colorDatabase.availableEnvironments().randomElement() ?? "forest"
                        enteredColors = []
                        showResults = false
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                } else {
                    Text("Here are more suggestions:")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(suggestedColors, id: \.id) { info in
                                ColorInfoPanel(colorInfo: info) {
                                    selectedColorInfo = info
                                    showColorDetail = true
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }

                if !unusualColors.isEmpty {
                    Text("You thought of some colors we didn't: \(unusualColors.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundColor(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if currentEnvironment.isEmpty {
                currentEnvironment = colorDatabase.availableEnvironments().randomElement() ?? "forest"
            }
        }
        .sheet(isPresented: $showColorDetail) {
            if let colorInfo = selectedColorInfo {
                ColorDetailView(color: colorInfo)
            }
        }
    }
}

struct ColorPill: View {
    let name: String
    let info: ColorInfo?

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(info?.color ?? Color.gray)
                .frame(width: 20, height: 20)
            Text(name)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(6)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
    }
}

#Preview {
    ImagineView()
}
