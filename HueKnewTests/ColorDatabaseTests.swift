import XCTest
@testable import HueKnew

final class ColorDatabaseTests: XCTestCase {
    
    var colorDatabase: ColorDatabase!
    
    override func setUp() {
        super.setUp()
        colorDatabase = ColorDatabase.shared
    }
    
    override func tearDown() {
        colorDatabase = nil
        super.tearDown()
    }
    
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
}

