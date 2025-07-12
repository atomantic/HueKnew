//
//  GameView.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI

struct GameView: View {
    @Bindable var gameModel: GameModel
    @State private var showingColorDictionary = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            if gameModel.currentPhase == .learning || gameModel.currentPhase == .challenge {
                HeaderView(
                    score: gameModel.score,
                    level: gameModel.level,
                    timeRemaining: 0, // No timer in learning mode
                    currentStreak: gameModel.streak,
                    bestStreak: gameModel.bestStreak
                )
                .padding(.horizontal)
                .padding(.top)
            }
            
            Spacer()
            
            // Game Content based on current phase
            Group {
                switch gameModel.currentPhase {
                case .menu:
                    menuScreen
                case .learning:
                    learningScreen
                case .challenge:
                    challengeScreen
                case .results:
                    resultsScreen
                }
            }
            
            
        }
        
    }
    
    // MARK: - Screen Views
    
    private var menuScreen: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Game logo/title
                VStack(spacing: 16) {
                    Text("Hue Knew")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Embark on a journey to discover color distinctions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Category selection
            VStack(spacing: 16) {
                Text("Choose a category to study:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(ColorCategory.allCases.prefix(6), id: \.self) { category in
                        CategoryCard(category: category) {
                            gameModel.startLearningSession(category: category)
                        }
                    }
                }
            }
            
            // Quick start options
            VStack(spacing: 12) {
                Text("Or choose by difficulty:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        DifficultyButton(difficulty: difficulty) {
                            gameModel.startLearningSession(difficulty: difficulty)
                        }
                    }
                }
            }
            
            // Random start button
            Button(action: { gameModel.resumeOrStartGame() }) {
                Text("Play")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Color Dictionary button
            Button(action: { showingColorDictionary = true }) {
                Text("Browse Color Dictionary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .sheet(isPresented: $showingColorDictionary) {
            ColorDictionaryView()
        }
    }
    
    private var learningScreen: some View {
        Group {
            if let colorPair = gameModel.currentColorPair {
                LearningView(colorPair: colorPair) {
                    gameModel.startChallengeFromLearning()
                }
            } else {
                Text("Loading...")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var challengeScreen: some View {
        Group {
            if let colorPair = gameModel.currentColorPair {
                ChallengeView(
                    colorPair: colorPair,
                    challengeType: gameModel.currentChallengeType
                ) { isCorrect in
                    gameModel.handleChallengeAnswer(isCorrect)
                }
            } else {
                Text("Loading...")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var resultsScreen: some View {
        VStack(spacing: 30) {
            // Session complete header
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Session Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Great job learning new colors!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Statistics
            VStack(spacing: 20) {
                HStack {
                    StatCard(title: "Accuracy", value: String(format: "%.1f%%", gameModel.accuracy * 100), color: .blue)
                    StatCard(title: "Best Streak", value: "\(gameModel.bestStreak)", color: .orange)
                }
                
                HStack {
                    StatCard(title: "Total Score", value: "\(gameModel.score)", color: .green)
                    StatCard(title: "Colors Learned", value: "\(gameModel.learnedPairsCount)/\(gameModel.totalPairsCount)", color: .purple)
                }
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: { gameModel.startLearningSession() }) {
                    Text("Start Another Session")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: { gameModel.endSession() }) {
                    Text("Back to Menu")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}

// MARK: - Helper Views

struct CategoryCard: View {
    let category: ColorCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(category.emoji)
                    .font(.system(size: 40))
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultyButton: View {
    let difficulty: DifficultyLevel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(difficulty.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(difficulty.color)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GameView(gameModel: GameModel())
}
