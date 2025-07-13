import XCTest
@testable import HueKnew

final class GameModelTests: XCTestCase {
    
    var gameModel: GameModel!
    
    override func setUp() {
        super.setUp()
        gameModel = GameModel()
    }
    
    override func tearDown() {
        gameModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(gameModel.currentPhase, .menu)
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.level, 1)
        XCTAssertEqual(gameModel.streak, 0)
        XCTAssertEqual(gameModel.bestStreak, 0)
        XCTAssertEqual(gameModel.totalQuestionsAnswered, 0)
        XCTAssertEqual(gameModel.correctAnswers, 0)
        XCTAssertFalse(gameModel.isGameActive)
        XCTAssertFalse(gameModel.isPaused)
    }
    
    func testStartLearningSession() {
        gameModel.startLearningSession()
        
        XCTAssertEqual(gameModel.currentPhase, .learning)
        XCTAssertTrue(gameModel.isGameActive)
        XCTAssertEqual(gameModel.questionsInCurrentSession, 0)
        XCTAssertNotNil(gameModel.currentColorPair)
    }
    
    func testStartLearningSessionWithCategory() {
        gameModel.startLearningSession(category: .blues)
        
        XCTAssertEqual(gameModel.selectedCategory, .blues)
        XCTAssertEqual(gameModel.currentPhase, .learning)
        XCTAssertTrue(gameModel.isGameActive)
    }
    
    func testStartLearningSessionWithDifficulty() {
        gameModel.startLearningSession(difficulty: .advanced)
        
        XCTAssertEqual(gameModel.selectedDifficulty, .advanced)
        XCTAssertEqual(gameModel.currentPhase, .learning)
        XCTAssertTrue(gameModel.isGameActive)
    }
    
    func testStartChallengeFromLearning() {
        gameModel.startLearningSession()
        gameModel.startChallengeFromLearning()
        
        XCTAssertEqual(gameModel.currentPhase, .challenge)
        XCTAssertTrue(ChallengeType.allCases.contains(gameModel.currentChallengeType))
    }
    
    func testHandleCorrectAnswer() {
        gameModel.startLearningSession()
        let initialScore = gameModel.score
        
        gameModel.handleChallengeAnswer(true)
        
        XCTAssertGreaterThan(gameModel.score, initialScore)
        XCTAssertEqual(gameModel.streak, 1)
        XCTAssertEqual(gameModel.correctAnswers, 1)
        XCTAssertEqual(gameModel.totalQuestionsAnswered, 1)
        XCTAssertEqual(gameModel.questionsInCurrentSession, 1)
    }
    
    func testHandleIncorrectAnswer() {
        gameModel.startLearningSession()
        
        gameModel.handleChallengeAnswer(false)
        
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.streak, 0)
        XCTAssertEqual(gameModel.correctAnswers, 0)
        XCTAssertEqual(gameModel.totalQuestionsAnswered, 1)
        XCTAssertEqual(gameModel.questionsInCurrentSession, 1)
    }
    
    func testStreakBuilding() {
        gameModel.startLearningSession()
        
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(true)
        
        XCTAssertEqual(gameModel.streak, 3)
        XCTAssertEqual(gameModel.bestStreak, 3)
    }
    
    func testStreakReset() {
        gameModel.startLearningSession()
        
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(false)
        
        XCTAssertEqual(gameModel.streak, 0)
        XCTAssertEqual(gameModel.bestStreak, 2)
    }
    
    func testSessionCompletionMovesToResultsPhase() {
        gameModel.startLearningSession()
        
        for _ in 0..<gameModel.maxQuestionsPerSession {
            gameModel.handleChallengeAnswer(true)
        }
        
        XCTAssertEqual(gameModel.currentPhase, .results)
    }
    
    func testResumeOrStartGameWhenNotActive() {
        // Test starting new game when no game is active
        XCTAssertFalse(gameModel.isGameActive)
        
        gameModel.resumeOrStartGame()
        
        XCTAssertEqual(gameModel.currentPhase, .learning)
        XCTAssertTrue(gameModel.isGameActive)
    }
    
    func testResumeOrStartGameWhenActive() {
        // Test resuming existing game when game is already active
        gameModel.startLearningSession()
        gameModel.currentPhase = .menu
        XCTAssertTrue(gameModel.isGameActive)
        
        gameModel.resumeOrStartGame()
        
        XCTAssertEqual(gameModel.currentPhase, .learning)
        XCTAssertTrue(gameModel.isGameActive)
    }
    
    func testGoToMenu() {
        gameModel.startLearningSession()
        gameModel.goToMenu()
        
        XCTAssertEqual(gameModel.currentPhase, .menu)
    }
    
    func testEndSession() {
        gameModel.startLearningSession()
        gameModel.endSession()
        
        XCTAssertFalse(gameModel.isGameActive)
        XCTAssertEqual(gameModel.currentPhase, .menu)
    }
    
    func testAccuracyCalculation() {
        gameModel.startLearningSession()
        
        // Initially should be 0
        XCTAssertEqual(gameModel.accuracy, 0.0)
        
        // After some answers
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(false)
        
        XCTAssertEqual(gameModel.accuracy, 2.0/3.0, accuracy: 0.01)
    }
    
    func testResetProgress() {
        gameModel.startLearningSession()
        gameModel.handleChallengeAnswer(true)
        gameModel.handleChallengeAnswer(true)
        
        gameModel.resetProgress()
        
        XCTAssertEqual(gameModel.score, 0)
        XCTAssertEqual(gameModel.level, 1)
        XCTAssertEqual(gameModel.streak, 0)
        XCTAssertEqual(gameModel.bestStreak, 0)
        XCTAssertEqual(gameModel.totalQuestionsAnswered, 0)
        XCTAssertEqual(gameModel.correctAnswers, 0)
        XCTAssertTrue(gameModel.masteredPairs.isEmpty)
        XCTAssertNil(gameModel.currentColorPair)
        XCTAssertEqual(gameModel.currentChallengeType, .nameToColor)
        XCTAssertEqual(gameModel.questionsInCurrentSession, 0)
        XCTAssertNil(gameModel.selectedCategory)
        XCTAssertNil(gameModel.selectedDifficulty)
        XCTAssertNil(gameModel.selectedHSBFilter)
        XCTAssertFalse(gameModel.isGameActive)
        XCTAssertFalse(gameModel.isPaused)
        XCTAssertEqual(gameModel.currentPhase, .menu)
    }
    
    func testMasteredPairsTracking() {
        gameModel.startLearningSession()
        guard let currentPair = gameModel.currentColorPair else {
            XCTFail("No current color pair generated")
            return
        }
        
        gameModel.handleChallengeAnswer(true)
        
        XCTAssertTrue(gameModel.masteredPairs.contains(currentPair.id))
    }
    
    func testLearnedPairsCount() {
        gameModel.startLearningSession()
        
        let initialCount = gameModel.learnedPairsCount
        gameModel.handleChallengeAnswer(true)
        
        XCTAssertEqual(gameModel.learnedPairsCount, initialCount + 1)
    }
}

