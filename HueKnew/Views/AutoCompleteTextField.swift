
import SwiftUI

struct AutoCompleteTextField: View {
    @Binding var text: String
    var suggestions: [String]
    var onCommit: (String) -> Void // Changed from onSelect to onCommit

    var body: some View {
        VStack {
            TextField("Enter colors...", text: $text, onCommit: {
                onCommit(text) // Pass the current text to the commit handler
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if !suggestions.isEmpty {
                List(suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .onTapGesture {
                            onCommit(suggestion) // Commit the tapped suggestion
                        }
                }
                .frame(height: 150)
            }
        }
    }
}
