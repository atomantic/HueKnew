//
//  GameModel.swift
//  Hue Knew
//
//  Created by Adam Eivy on 7/11/25.
//

import SwiftUI
import Foundation

enum GamePhase {
    case menu
    case learning
    case challenge
    case results
}

@Observable
class GameModel {
    // Game state
    var currentPhase: GamePhase = .menu
    var score: Int = 0
    var level: Int = 1
    var streak: Int = 0
    var bestStreak: Int = 0
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    
    // Current session
    var currentColorPair: ColorPair?
    var currentChallengeType: ChallengeType = .nameToColor
    var questionsInCurrentSession: Int = 0
    var maxQuestionsPerSession: Int = 10
    
    // Learning progress
    var masteredPairs: Set<String> = []
    var selectedCategory: ColorCategory?
    var selectedDifficulty: DifficultyLevel?
    
    // Game flow control
    var isGameActive: Bool = false
    var isPaused: Bool = false
    
    private let colorDatabase = ColorDatabase.shared
    
    // MARK: - Game Flow Methods
    
    func startLearningSession(category: ColorCategory? = nil, difficulty: DifficultyLevel? = nil) {
        selectedCategory = category
        selectedDifficulty = difficulty
        questionsInCurrentSession = 0
        isGameActive = true
        
        // Get next color pair to learn
        generateNextColorPair()
        currentPhase = .learning
    }
    
    func startChallengeFromLearning() {
        currentPhase = .challenge
        currentChallengeType = ChallengeType.allCases.randomElement() ?? .nameToColor
    }
    
    func handleChallengeAnswer(_ isCorrect: Bool) {
        totalQuestionsAnswered += 1
        questionsInCurrentSession += 1
        
        if isCorrect {
            correctAnswers += 1
            streak += 1
            score += calculateScore()
            
            if streak > bestStreak {
                bestStreak = streak
            }
            
            // Mark pair as mastered if answered correctly multiple times
            if let currentPair = currentColorPair {
                masteredPairs.insert(currentPair.id)
            }
        } else {
            streak = 0
            score = max(0, score - 5)
        }
        
        // Check if session is complete
        if questionsInCurrentSession >= maxQuestionsPerSession {
            currentPhase = .results
        } else {
            // Continue with next challenge
            generateNextColorPair()
            currentPhase = .learning
        }
    }
    
    func resumeOrStartGame() {
        if isGameActive {
            currentPhase = .learning
        } else {
            startLearningSession()
        }
    }

    func goToMenu() {
        currentPhase = .menu
    }
    
    func endSession() {
        isGameActive = false
        currentPhase = .menu
        
        // Update level based on performance
        updateLevel()
    }
    
    // MARK: - Helper Methods
    
    private func generateNextColorPair() {
        var availablePairs: [ColorPair] = []
        
        // Filter by category if selected
        if let category = selectedCategory {
            availablePairs = colorDatabase.getColorPairs(for: category)
        } else if let difficulty = selectedDifficulty {
            availablePairs = colorDatabase.getColorPairs(for: difficulty)
        } else {
            availablePairs = colorDatabase.getAllColorPairs()
        }
        
        // Prefer pairs that haven't been mastered yet
        let unmasteredPairs = availablePairs.filter { !masteredPairs.contains($0.id) }
        
        if !unmasteredPairs.isEmpty {
            currentColorPair = unmasteredPairs.randomElement()
        } else {
            currentColorPair = availablePairs.randomElement()
        }
    }
    
    private func calculateScore() -> Int {
        let baseScore = 10
        let levelMultiplier = level
        let streakBonus = min(streak, 10) // Cap streak bonus at 10
        let difficultyMultiplier = currentColorPair?.difficultyLevel == .expert ? 3 : 
                                   currentColorPair?.difficultyLevel == .advanced ? 2 : 1
        
        return baseScore * levelMultiplier * difficultyMultiplier + streakBonus
    }
    
    private func updateLevel() {
        // Level up based on accuracy and total questions answered
        let accuracy = totalQuestionsAnswered > 0 ? Double(correctAnswers) / Double(totalQuestionsAnswered) : 0
        
        if accuracy >= 0.8 && totalQuestionsAnswered >= level * 20 {
            level += 1
        }
    }
    
    // MARK: - Statistics
    
    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestionsAnswered)
    }
    
    var sessionAccuracy: Double {
        guard questionsInCurrentSession > 0 else { return 0 }
        // This would need more detailed tracking for session-specific accuracy
        return accuracy
    }
    
    var learnedPairsCount: Int {
        masteredPairs.count
    }
    
    var totalPairsCount: Int {
        colorDatabase.getAllColorPairs().count
    }
}
