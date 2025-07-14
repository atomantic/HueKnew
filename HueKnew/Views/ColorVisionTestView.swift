import SwiftUI

struct ColorVisionTestView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameModel: GameModel

    @State private var currentIndex = 0
    @State private var correctCount = 0

    private let testPairs: [ColorPair] = Array(ColorDatabase.shared.getAllColorPairs().filter { $0.difficultyLevel == .easy }.shuffled().prefix(3))

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if currentIndex < testPairs.count {
                    testQuestion(for: testPairs[currentIndex])
                } else {
                    testResult
                }
            }
            .padding()
            .navigationTitle("Color Vision Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func testQuestion(for pair: ColorPair) -> some View {
        VStack(spacing: 24) {
            Text("Select \(pair.primaryColor.name)")
                .font(.headline)

            HStack(spacing: 24) {
                ForEach(pair.allColors) { color in
                    ColorOptionCard(colorInfo: color,
                                    isSelected: false,
                                    showName: false,
                                    borderColor: nil) {
                        handleSelection(color == pair.primaryColor)
                    }
                }
            }
        }
    }

    private var testResult: some View {
        VStack(spacing: 16) {
            if correctCount >= testPairs.count - 1 {
                Text("No issues detected")
                    .font(.title2)
                Button("Done") {
                    gameModel.colorVisionDeficient = false
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Color vision assistance enabled")
                    .font(.title2)
                Button("Done") {
                    gameModel.colorVisionDeficient = true
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func handleSelection(_ correct: Bool) {
        if correct { correctCount += 1 }
        currentIndex += 1
    }
}

#Preview {
    ColorVisionTestView(gameModel: GameModel())
}
