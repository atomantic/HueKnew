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
        let line = "#FF0000\treds\tRed\tnil\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 5)
        XCTAssertEqual(fields[0], "#FF0000")
        XCTAssertEqual(fields[1], "reds")
        XCTAssertEqual(fields[2], "Red")
        XCTAssertEqual(fields[3], "nil")
        XCTAssertEqual(fields[4], "A bright red color")
    }
    
    func testTSVParserQuotedField() {
        let line = "#FF0000\treds\t\"Red, the primary color\"\tnil\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 5)
        XCTAssertEqual(fields[2], "Red, the primary color")
    }
    
    func testTSVParserEscapedQuote() {
        let line = "#FF0000\treds\t\"Red with \"\"quotes\"\" inside\"\tnil\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 5)
        XCTAssertEqual(fields[2], "Red with \"quotes\" inside")
    }
    
    func testTSVParserTabInQuotedField() {
        let line = "#FF0000\treds\t\"Red\twith\ttabs\"\tnil\tA bright red color"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 5)
        XCTAssertEqual(fields[2], "Red\twith\ttabs")
    }
    
    func testTSVParserEmptyFields() {
        let line = "#FF0000\treds\tRed\t\t"
        let fields = TSVParser.parseTSVLine(line)
        XCTAssertEqual(fields.count, 5)
        XCTAssertEqual(fields[0], "#FF0000")
        XCTAssertEqual(fields[1], "reds")
        XCTAssertEqual(fields[2], "Red")
        XCTAssertEqual(fields[3], "")
        XCTAssertEqual(fields[4], "")
    }

    // MARK: - Color Database Tests
    func testLoadColorsFromTSV() {
        colorDatabase.loadColorsFromTSV()
        let allColors = colorDatabase.getAllColors()
        XCTAssertFalse(allColors.isEmpty, "Colors should be loaded from TSV")
        
        // Verify that some colors have environments and some don't
        let pineGreen = allColors.first { $0.name == "Pine Green" }
        XCTAssertEqual(pineGreen?.environment, "forest")
        
        let redColor = allColors.first { $0.name == "Red" }
        XCTAssertNil(redColor?.environment)
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
        let color1 = ColorInfo(name: "Red", hexValue: "#FF0000", description: "", category: .reds, environment: nil)
        let color2 = ColorInfo(name: "Blue", hexValue: "#0000FF", description: "", category: .blues, environment: nil)
        let difference = colorDatabase.calculateColorDifference(color1: color1, color2: color2)
        
        XCTAssertGreaterThan(difference, 0.0, "There should be a difference between red and blue")
    }
    
    func testTemperatureCategory() {
        let color = ColorInfo(name: "Cyan", hexValue: "#00FFFF", description: "", category: .blues, environment: nil)
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
            XCTFail("Required colors not found. Available colors: \(colors.map { $0.name }.joined(separator: ", "))")
            return
        }

        let comparisons = colorDatabase.getColorComparisons(color1: burnt, color2: terra)
        XCTAssertFalse(comparisons.isEmpty, "Burnt Sienna and Terra Cotta should have distinguishing characteristics")
    }

    func testCarnelianVsFirebrickComparisons() {
        let colors = colorDatabase.getAllColors()
        guard
            let carnelian = colors.first(where: { $0.name == "Carnelian" }),
            let firebrick = colors.first(where: { $0.name == "Firebrick" })
        else {
            XCTFail("Required colors not found. Available colors: \(colors.map { $0.name }.joined(separator: ", "))")
            return
        }

        let comparisons = colorDatabase.getColorComparisons(color1: carnelian, color2: firebrick)
        XCTAssertFalse(comparisons.isEmpty, "Carnelian and Firebrick should have distinguishing characteristics")
    }
}

