import XCTest

final class ImagineViewUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to make sure the application is launched once before each test method.
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to the Imagine tab
        app.buttons["Imagine"].tap()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImagineViewLoadsAndAcceptsInput() throws {
        let app = XCUIApplication()
        
        // Check if the Imagine view elements are present
        XCTAssertTrue(app.staticTexts["Imagine"].exists)
        XCTAssertTrue(app.staticTexts["Imagine a forest. What colors do you see?"].exists)
        
        let colorTextField = app.textFields["Enter colors..."]
        XCTAssertTrue(colorTextField.exists)
        
        // Type a color and check if it's processed
        colorTextField.tap()
        colorTextField.typeText("green\n") // Type 'green' and hit enter
        
        // Check if 'green' is added as an identified color
        XCTAssertTrue(app.staticTexts["Green"].exists)
        
        // Type another color that might be unusual
        colorTextField.typeText("purple\n")
        
        // Check if 'purple' is in the unusual colors section
        XCTAssertTrue(app.staticTexts["Purple"].exists)
    }

    func testAutocompleteSuggestions() throws {
        let app = XCUIApplication()
        let colorTextField = app.textFields["Enter colors..."]
        
        colorTextField.tap()
        colorTextField.typeText("bl") // Type 'bl' to trigger autocomplete
        
        // Check for suggestions (e.g., Blue, Black)
        XCTAssertTrue(app.staticTexts["Blue"].exists)
        XCTAssertTrue(app.staticTexts["Black"].exists)
        
        // Select a suggestion
        app.staticTexts["Blue"].tap()
        
        // Verify that Blue is now an identified color
        XCTAssertTrue(app.staticTexts["Blue"].exists)
        XCTAssertEqual(colorTextField.value as? String, "") // Text field should be cleared
    }
}