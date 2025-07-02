import SwiftUI

final class GameViewModel: ObservableObject {
    @Published var targetColor: Color = .red
    @Published var selectedColor: Color = .white
    
    init() {
        newRound()
    }
    
    func newRound() {
        targetColor = Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
        selectedColor = .white
    }
}
