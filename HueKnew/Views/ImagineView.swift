
import SwiftUI

struct ImagineView: View {
    @State private var userInput: String = ""
    @State private var identifiedColors: [ColorInfo] = []
    @State private var suggestedColors: [ColorInfo] = []
    @State private var unusualColors: [String] = []
    @State private var showColorDetail: Bool = false
    @State private var selectedColor: ColorInfo? = nil
    @State private var environmentColors: [ColorInfo] = []
    @State private var autocompleteSuggestions: [String] = []
    @State private var allColorNames: [String] = [] // To store all color names for autocomplete
    @State private var allColors: [ColorInfo] = [] // To store all ColorInfo objects for lookup
    
    let environmentPrompt = "Imagine a forest. What colors do you see?"
    let environment = "forest"
    
    var body: some View {
        VStack {
            Text("Imagine")
                .font(.largeTitle)
                .padding()
            
            Text(environmentPrompt)
                .padding()
            
            AutoCompleteTextField(text: $userInput, suggestions: autocompleteSuggestions) { committedText in
                processInput(committedText)
            }
            .padding()
            
            // Display identified colors
            if !identifiedColors.isEmpty {
                Text("Your Colors")
                    .font(.headline)
                    .padding(.top)
                
                // Use a LazyVGrid or similar for better layout of pills
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(identifiedColors) { color in
                        ColorInfoPanelView(colorInfo: color) {
                            self.selectedColor = color
                            self.showColorDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Display unusual colors
            if !unusualColors.isEmpty {
                Text("Unusual Colors (not in this environment)")
                    .font(.headline)
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(unusualColors, id: \.self) { colorName in
                        // Try to find the ColorInfo for unusual colors to display as a pill
                        if let colorInfo = ColorDatabase.shared.getAllColors().first(where: { $0.name.lowercased() == colorName.lowercased() }) {
                            ColorInfoPanelView(colorInfo: colorInfo) {
                                self.selectedColor = colorInfo
                                self.showColorDetail = true
                            }
                        } else {
                            // If not found in the database, display as plain text
                            Text(colorName)
                                .padding(8)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Display suggested colors
            ScrollView {
                VStack(alignment: .leading) {
                    if !suggestedColors.isEmpty {
                        Text("Suggested Colors")
                            .font(.headline)
                            .padding(.top)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(suggestedColors) { color in
                                ColorInfoPanelView(colorInfo: color) {
                                    self.selectedColor = color
                                    self.showColorDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear(perform: loadInitialData) // Changed to loadInitialData
        .onChange(of: userInput) { value in // Simplified onChange
            updateSuggestions(for: value)
        }
        .sheet(isPresented: $showColorDetail) {
            if let color = selectedColor {
                ColorDetailView(color: color)
            }
        }
    }
    
    private func loadInitialData() {
        environmentColors = ColorDatabase.shared.getColors(for: environment)
        allColors = ColorDatabase.shared.getAllColors() // Load all colors
        allColorNames = allColors.map { $0.name } // Extract all color names
        updateSuggestedColors() // Initial suggestions
    }
    
    private func processInput(_ input: String) {
        let components = input.components(separatedBy: CharacterSet(charactersIn: ",")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

        for cleanedInput in components {
            if let matchedColor = allColors.first(where: { $0.name.lowercased() == cleanedInput.lowercased() }) {
                if !identifiedColors.contains(matchedColor) {
                    identifiedColors.append(matchedColor)
                }
                // Check if it's unusual for this environment
                if !environmentColors.contains(matchedColor) && !unusualColors.contains(matchedColor.name) {
                    unusualColors.append(matchedColor.name)
                }
            } else {
                // If not found in the database at all, add to unusualColors as plain text
                if !unusualColors.contains(cleanedInput) {
                    unusualColors.append(cleanedInput)
                }
            }
        }

        userInput = "" // Clear input after processing
        updateSuggestedColors()
    }
    
    private func updateSuggestions(for input: String) {
        if input.count < 2 { // Autocomplete after 2 characters
            autocompleteSuggestions = []
        } else {
            autocompleteSuggestions = allColorNames.filter { $0.lowercased().starts(with: input.lowercased()) }
        }
    }
    
    private func updateSuggestedColors() {
        // Suggest colors from the environment that haven't been identified yet
        suggestedColors = environmentColors.filter { !identifiedColors.contains($0) }
    }
}

struct ImagineView_Previews: PreviewProvider {
    static var previews: some View {
        ImagineView()
    }
}
