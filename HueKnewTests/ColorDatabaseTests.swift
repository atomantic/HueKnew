import XCTest
@testable import HueKnew

final class ColorDatabaseTests: XCTestCase {
    
    var colorDatabase: ColorDatabase!
    
    override func setUpWithError() throws {
        colorDatabase = ColorDatabase.shared
    }
    
    override func tearDownWithError() throws {
        colorDatabase = nil
    }
    
    // MARK: - TSV Parser Tests
    func testTSVParserBasicLine() {
        let line = "red\t#FF0000\tRed\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[0], "red")
        XCTAssertEqual(fields[1], "#FF0000")
        XCTAssertEqual(fields[2], "Red")
        XCTAssertEqual(fields[3], "A bright red color")
    }
    
    func testTSVParserQuotedField() {
        let line = "red\t#FF0000\t\"Red, the primary color\"\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[2], "Red, the primary color")
    }
    
    func testTSVParserEscapedQuote() {
        let line = "red\t#FF0000\t\"Red with \"\"quotes\"\" inside\"\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[2], "Red with \"quotes\" inside")
    }
    
    func testTSVParserTabInQuotedField() {
        let line = "red\t#FF0000\t\"Red\twith\ttabs\"\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[2], "Red\twith\ttabs")
    }
    
    func testTSVParserEmptyFields() {
        let line = "red\t\t\t"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[0], "red")
        XCTAssertEqual(fields[1], "")
        XCTAssertEqual(fields[2], "")
        XCTAssertEqual(fields[3], "")
    }

    // MARK: - Color Database Tests
    func testLoadColorsFromTSV() {
        // Ensure the method does not crash
        // Data can be stubbed or mocked for more robust testing
        colorDatabase.loadColorsFromTSV()
        let allColors = colorDatabase.getAllColors()
        XCTAssertFalse(allColors.isEmpty, "Colors should be loaded from TSV")
    }
    
    func testGenerateColorPairs() {
        let colorPairs = colorDatabase.getAllColorPairs()
        XCTAssertFalse(colorPairs.isEmpty, "Color pairs should be generated")
    }
    
    func testGetColorPairsByCategory() {
        let colorPairs = colorDatabase.getColorPairs(for: .reds)
        XCTAssertFalse(colorPairs.isEmpty, "Should return color pairs for category 'Reds'")
    }
    
    func testGetColorPairsMatchingHSBFilter() {
        let filter = HSBFilter(hue: 180.0, saturation: 0.5, brightness: 0.5)
        let colorPairs = colorDatabase.getColorPairs(matching: filter)
        
        XCTAssertNotNil(colorPairs)
    }
    
    func testCalculateColorDifference() {
        let color1 = ColorInfo(name: "Red", hexValue: "#FF0000", description: "", category: .reds)
        let color2 = ColorInfo(name: "Blue", hexValue: "#0000FF", description: "", category: .blues)
        let difference = colorDatabase.calculateColorDifference(color1: color1, color2: color2)
        
        XCTAssertGreaterThan(difference, 0.0, "There should be a difference between red and blue")
    }
    
    func testTemperatureCategory() {
        let color = ColorInfo(name: "Cyan", hexValue: "#00FFFF", description: "", category: .blues)
        let temperature = colorDatabase.temperatureCategory(for: color)

        XCTAssertEqual(temperature, "cool", "Cyan should be classified as a cool color")
    }

    func testGetMostSimilarColors() {
        let allColors = colorDatabase.getAllColors()
        guard let firstColor = allColors.first else {
            XCTFail("No colors loaded")
            return
        }

        let similar = colorDatabase.getMostSimilarColors(to: firstColor, count: 2)
        XCTAssertEqual(similar.count, 2)
        XCTAssertFalse(similar.contains(firstColor))
    }

    func testComparisonsBetweenSimilarReds() {
        let colors = colorDatabase.getAllColors()
        guard
            let burnt = colors.first(where: { $0.name == "Burnt Sienna" }),
            let terra = colors.first(where: { $0.name == "Terra Cotta" })
        else {
            XCTFail("Required colors not found")
            return
        }

        let comparisons = colorDatabase.getColorComparisons(color1: burnt, color2: terra)
        XCTAssertFalse(comparisons.isEmpty, "Burnt Sienna and Terra Cotta should have distinguishing characteristics")
    }
}

