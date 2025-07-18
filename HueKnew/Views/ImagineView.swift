import SwiftUI

struct ImagineView: View {
    @State private var currentEnvironment: String = ""
    @State private var inputText = ""
    @State private var enteredColors: [String] = []
    @State private var showResults = false

    private let colorDatabase = ColorDatabase.shared

    private var autocompleteSuggestions: [String] {
        guard !inputText.isEmpty else { return [] }
        let all = colorDatabase.getAllColors().map { $0.name }
        return all.filter { $0.lowercased().hasPrefix(inputText.lowercased()) }
            .sorted()
            .prefix(5)
            .map { $0 }
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

    private var article: String {
        guard let first = currentEnvironment.first else { return "a" }
        return ["a", "e", "i", "o", "u"].contains(String(first).lowercased()) ? "an" : "a"
    }

    private var promptView: some View {
        Text("Type colors you imagine in \(article) ") + Text(currentEnvironment).bold() + Text(".")
            .font(.subheadline)
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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(enteredColors, id: \.self) { name in
                            ColorPill(name: name, info: colorDatabase.color(named: name))
                        }
                    }
                }
            }

            if !autocompleteSuggestions.isEmpty {
                VStack(alignment: .leading) {
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
                .background(Color(.systemGray6))
            }

            Button("Done") {
                showResults = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            if showResults {
                if !unusualColors.isEmpty {
                    Text("You thought of some interesting colors we didn't think of for this environment: \(unusualColors.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }

                ForEach(suggestedColors, id: \.id) { info in
                    ColorInfoPanel(colorInfo: info) {}
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
        }
        .padding(6)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
    }
}

#Preview {
    ImagineView()
}
