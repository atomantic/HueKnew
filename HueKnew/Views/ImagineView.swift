import SwiftUI

struct ImagineView: View {
    @State private var selectedEnvironment = "forest"
    private let environments = ["forest", "desert", "seascape", "city"]
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
        colorDatabase.colors(forEnvironment: selectedEnvironment)
    }

    private var suggestedColors: [ColorInfo] {
        let enteredSet = Set(enteredColors.map { $0.lowercased() })
        return environmentColors.filter { !enteredSet.contains($0.name.lowercased()) }.prefix(3).map { $0 }
    }

    private var unusualColors: [String] {
        let envSet = Set(environmentColors.map { $0.name.lowercased() })
        return enteredColors.filter { !envSet.contains($0.lowercased()) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Imagine")
                .font(.largeTitle)
                .bold()

            Picker("Environment", selection: $selectedEnvironment) {
                ForEach(environments, id: \.self) { env in
                    Text(env.capitalized).tag(env)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Text("Type colors you imagine in a \(selectedEnvironment).")
                .font(.subheadline)

            TextField("Enter color", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    guard !inputText.isEmpty else { return }
                    enteredColors.append(inputText)
                    inputText = ""
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

            if !enteredColors.isEmpty {
                Text("You entered: \(enteredColors.joined(separator: ", "))")
                    .font(.footnote)
            }

            Button("Done") {
                showResults = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            if showResults {
                if !unusualColors.isEmpty {
                    Text("Unusual colors: \(unusualColors.joined(separator: ", "))")
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
    }
}

#Preview {
    ImagineView()
}
