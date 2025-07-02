import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.targetColor)
                .frame(width: 200, height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
            ColorPicker("Select a color", selection: $viewModel.selectedColor)
                .padding()
            Button("New Color") {
                viewModel.newRound()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
