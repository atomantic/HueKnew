import XCTest
import SwiftUI
@testable import HueKnew

final class ColorPairTests: XCTestCase {
    
    var colorInfo1: ColorInfo!
    var colorInfo2: ColorInfo!
    var colorPair: ColorPair!
    
    override func setUp() {
        super.setUp()
        colorInfo1 = ColorInfo(
            name: "Red",
            hexValue: "#FF0000",
            description: "Pure red color",
            category: .reds,
            environment: nil
        )
        colorInfo2 = ColorInfo(
            name: "Blue",
            hexValue: "#0000FF",
            description: "Pure blue color",
            category: .blues,
            environment: nil
        )
        colorPair = ColorPair(
            primaryColor: colorInfo1,
            comparisonColor: colorInfo2,
            learningNotes: "Red vs Blue comparison",
            category: .reds
        )
    }
    
    override func tearDown() {
        colorInfo1 = nil
        colorInfo2 = nil
        colorPair = nil
        super.tearDown()
    }
}

// MARK: - ColorInfo Tests
extension ColorPairTests {
    
    func testColorInfoInitialization() {
        XCTAssertEqual(colorInfo1.name, "Red")
        XCTAssertEqual(colorInfo1.hexValue, "#FF0000")
        XCTAssertEqual(colorInfo1.description, "Pure red color")
        XCTAssertEqual(colorInfo1.category, .reds)
    }
    
    func testColorInfoID() {
        XCTAssertEqual(colorInfo1.id, "Red")
    }
    
    func testRGBComponents() {
        let rgb = colorInfo1.rgbComponents
        XCTAssertEqual(rgb.red, 1.0, accuracy: 0.01)
        XCTAssertEqual(rgb.green, 0.0, accuracy: 0.01)
        XCTAssertEqual(rgb.blue, 0.0, accuracy: 0.01)
    }
    
    func testRGBComponentsBlue() {
        let rgb = colorInfo2.rgbComponents
        XCTAssertEqual(rgb.red, 0.0, accuracy: 0.01)
        XCTAssertEqual(rgb.green, 0.0, accuracy: 0.01)
        XCTAssertEqual(rgb.blue, 1.0, accuracy: 0.01)
    }
    
    func testHSBComponents() {
        let hsb = colorInfo1.hsbComponents
        XCTAssertEqual(hsb.hue, 0.0, accuracy: 1.0) // Red is at 0 degrees
        XCTAssertEqual(hsb.saturation, 1.0, accuracy: 0.01)
        XCTAssertEqual(hsb.brightness, 1.0, accuracy: 0.01)
    }
    
    func testHSBComponentsBlue() {
        let hsb = colorInfo2.hsbComponents
        XCTAssertEqual(hsb.hue, 240.0, accuracy: 1.0) // Blue is at 240 degrees
        XCTAssertEqual(hsb.saturation, 1.0, accuracy: 0.01)
        XCTAssertEqual(hsb.brightness, 1.0, accuracy: 0.01)
    }
    
    func testHexColorWithoutHash() {
        let colorWithoutHash = ColorInfo(
            name: "Green",
            hexValue: "00FF00",
            description: "Green without hash",
            category: .greens,
            environment: nil
        )
        let rgb = colorWithoutHash.rgbComponents
        XCTAssertEqual(rgb.red, 0.0, accuracy: 0.01)
        XCTAssertEqual(rgb.green, 1.0, accuracy: 0.01)
        XCTAssertEqual(rgb.blue, 0.0, accuracy: 0.01)
    }
    
    func testColorEquality() {
        let colorInfo1Copy = ColorInfo(
            name: "Red",
            hexValue: "#FF0000",
            description: "Pure red color",
            category: .reds,
            environment: nil
        )
        XCTAssertEqual(colorInfo1, colorInfo1Copy)
        XCTAssertNotEqual(colorInfo1, colorInfo2)
    }
}

// MARK: - ColorPair Tests
extension ColorPairTests {
    
    func testColorPairInitialization() {
        XCTAssertEqual(colorPair.primaryColor, colorInfo1)
        XCTAssertEqual(colorPair.comparisonColor, colorInfo2)
        XCTAssertEqual(colorPair.learningNotes, "Red vs Blue comparison")
        XCTAssertEqual(colorPair.category, .reds)
    }
    
    func testColorPairID() {
        XCTAssertEqual(colorPair.id, "Red-Blue")
    }
    
    func testAllColors() {
        let allColors = colorPair.allColors
        XCTAssertEqual(allColors.count, 2)
        XCTAssertTrue(allColors.contains(colorInfo1))
        XCTAssertTrue(allColors.contains(colorInfo2))
    }
    
    func testDifficultyLevel() {
        // Red and Blue should be intermediate difficulty due to moderate color difference
        XCTAssertEqual(colorPair.difficultyLevel, .intermediate)
    }
    
    func testDifficultyLevelSimilarColors() {
        // Create two similar colors for advanced difficulty
        let color1 = ColorInfo(
            name: "Light Red",
            hexValue: "#FF1111",
            description: "Light red",
            category: .reds,
            environment: nil
        )
        let color2 = ColorInfo(
            name: "Slightly Different Red",
            hexValue: "#FF0000",
            description: "Slightly different red",
            category: .reds,
            environment: nil
        )
        let similarPair = ColorPair(
            primaryColor: color1,
            comparisonColor: color2,
            learningNotes: "Similar reds",
            category: .reds
        )
        
        // This should be advanced since colors are very similar
        XCTAssertEqual(similarPair.difficultyLevel, .advanced)
    }
}

// MARK: - HSBFilter Tests
extension ColorPairTests {
    
    func testHSBFilterInitialization() {
        let filter = HSBFilter(hue: 180.0, saturation: 0.5, brightness: 0.7)
        
        XCTAssertEqual(filter.hueRange.lowerBound, 150.0)
        XCTAssertEqual(filter.hueRange.upperBound, 210.0)
        XCTAssertEqual(filter.saturationRange.lowerBound, 0.3, accuracy: 0.01)
        XCTAssertEqual(filter.saturationRange.upperBound, 0.7, accuracy: 0.01)
        XCTAssertEqual(filter.brightnessRange.lowerBound, 0.5, accuracy: 0.01)
        XCTAssertEqual(filter.brightnessRange.upperBound, 0.9, accuracy: 0.01)
    }
    
    func testHSBFilterBoundaries() {
        let filter = HSBFilter(hue: 10.0, saturation: 0.1, brightness: 0.1)
        
        // Should not go below 0
        XCTAssertGreaterThanOrEqual(filter.hueRange.lowerBound, 0.0)
        XCTAssertGreaterThanOrEqual(filter.saturationRange.lowerBound, 0.0)
        XCTAssertGreaterThanOrEqual(filter.brightnessRange.lowerBound, 0.0)
        
        // Should not go above limits
        XCTAssertLessThanOrEqual(filter.hueRange.upperBound, 360.0)
        XCTAssertLessThanOrEqual(filter.saturationRange.upperBound, 1.0)
        XCTAssertLessThanOrEqual(filter.brightnessRange.upperBound, 1.0)
    }
}

// MARK: - ColorCategory Tests
extension ColorPairTests {
    
    func testColorCategoryEmojis() {
        XCTAssertEqual(ColorCategory.yellows.emoji, "🟡")
        XCTAssertEqual(ColorCategory.blues.emoji, "🔵")
        XCTAssertEqual(ColorCategory.reds.emoji, "🔴")
        XCTAssertEqual(ColorCategory.greens.emoji, "🟢")
        XCTAssertEqual(ColorCategory.purples.emoji, "🟣")
        XCTAssertEqual(ColorCategory.oranges.emoji, "🟠")
        XCTAssertEqual(ColorCategory.neutrals.emoji, "⚪")
    }
    
    func testColorCategoryRawValues() {
        XCTAssertEqual(ColorCategory.yellows.rawValue, "Yellows")
        XCTAssertEqual(ColorCategory.blues.rawValue, "Blues")
        XCTAssertEqual(ColorCategory.reds.rawValue, "Reds")
    }
}

// MARK: - DifficultyLevel Tests
extension ColorPairTests {
    
    func testDifficultyLevelStarIcons() {
        XCTAssertEqual(DifficultyLevel.easy.starIcons, "⭐")
        XCTAssertEqual(DifficultyLevel.intermediate.starIcons, "⭐⭐")
        XCTAssertEqual(DifficultyLevel.advanced.starIcons, "⭐⭐⭐")
    }
    
    func testDifficultyLevelColors() {
        // Just verify they return colors without crashing
        XCTAssertNotNil(DifficultyLevel.easy.color)
        XCTAssertNotNil(DifficultyLevel.intermediate.color)
        XCTAssertNotNil(DifficultyLevel.advanced.color)
    }
}

// MARK: - ChallengeType Tests
extension ColorPairTests {
    
    func testChallengeTypeDescriptions() {
        XCTAssertEqual(ChallengeType.nameToColor.description, "Which color is")
        XCTAssertEqual(ChallengeType.colorToName.description, "What is this color called?")
    }
    
    func testChallengeTypeAllCases() {
        XCTAssertEqual(ChallengeType.allCases.count, 2)
        XCTAssertTrue(ChallengeType.allCases.contains(.nameToColor))
        XCTAssertTrue(ChallengeType.allCases.contains(.colorToName))
    }
}

// MARK: - Color Extension Tests
extension ColorPairTests {
    
    func testColorFromHex() {
        // Test 6-digit hex
        let redColor = Color(hex: "#FF0000")
        XCTAssertNotNil(redColor)
        
        // Test 3-digit hex
        let blueColor = Color(hex: "#00F")
        XCTAssertNotNil(blueColor)
        
        // Test 8-digit hex (with alpha)
        let alphaColor = Color(hex: "#FF0000FF")
        XCTAssertNotNil(alphaColor)
        
        // Test without hash
        let greenColor = Color(hex: "00FF00")
        XCTAssertNotNil(greenColor)
    }
}
