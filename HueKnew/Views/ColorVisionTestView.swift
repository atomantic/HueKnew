import SwiftUI

struct VisionQuestion {
    let prompt: String
    let colors: [Color]
    let correctIndex: Int
}

struct ColorVisionTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var questionIndex = 0
    @State private var correctAnswers = 0

    let completion: (Bool) -> Void

    private let questions: [VisionQuestion] = [
        VisionQuestion(prompt: "Select the green color", colors: [.red, .green], correctIndex: 1),
        VisionQuestion(prompt: "Select the blue color", colors: [.blue, .orange], correctIndex: 0),
        VisionQuestion(prompt: "Select the purple color", colors: [.yellow, .purple], correctIndex: 1)
    ]

    var body: some View {
        VStack(spacing: 40) {
            Text(questions[questionIndex].prompt)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: 40) {
                ForEach(0..<questions[questionIndex].colors.count, id: \.self) { index in
                    Circle()
                        .fill(questions[questionIndex].colors[index])
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            handleAnswer(index)
                        }
                }
            }
        }
    }

    private func handleAnswer(_ index: Int) {
        if index == questions[questionIndex].correctIndex {
            correctAnswers += 1
        }
        if questionIndex + 1 < questions.count {
            questionIndex += 1
        } else {
            let hasDeficiency = correctAnswers < questions.count
            completion(hasDeficiency)
            dismiss()
        }
    }
}

#Preview {
    ColorVisionTestView { _ in }
}
