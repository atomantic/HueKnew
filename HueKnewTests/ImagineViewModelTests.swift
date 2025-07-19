import XCTest
import SwiftUI
@testable import HueKnew

final class ImagineViewModelTests: XCTestCase {

    var viewModel: ImagineViewModel!
    var mockColorDatabase: MockColorDatabase!

    override func setUpWithError() throws {
        mockColorDatabase = MockColorDatabase()
        // Set up mock environment colors for "forest"
        mockColorDatabase.mockEnvironmentColors["forest"] = [
            ColorInfo(name: "Green", hexValue: "#00FF00", description: "", category: .greens),
            ColorInfo(name: "Blue", hexValue: "#0000FF", description: "", category: .blues),
            ColorInfo(name: "Brown", hexValue: "#A52A2A", description: "", category: .neutrals)
        ]
        viewModel = ImagineViewModel(colorDatabase: mockColorDatabase)
        viewModel.currentEnvironment = "forest"
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockColorDatabase = nil
    }

    func testUnusualColorsLogic() throws {
        // Simulate some entered colors, including one that should be unusual
        viewModel.enteredColors = ["Green", "Blue", "Purple", "NonExistentColor"]

        // Access the unusualColors computed property directly
        let unusualColors = viewModel.unusualColors

        XCTAssertNotNil(unusualColors, "unusualColors should not be nil")
        XCTAssertTrue(unusualColors.contains("Purple"), "Purple should be identified as unusual")
        XCTAssertTrue(unusualColors.contains("NonExistentColor"), "NonExistentColor should be identified as unusual")
        XCTAssertFalse(unusualColors.contains("Green"), "Green should not be unusual for 'forest' environment")
        XCTAssertFalse(unusualColors.contains("Blue"), "Blue should not be unusual for 'forest' environment")
    }
}
