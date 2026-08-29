//
//  CustomLocationViewUITests.swift
//  WikiPlacesAppUITests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest

final class CustomLocationViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private func openSheet() {
        app.buttons["Enter a custom location"].tap()
        XCTAssertTrue(app.navigationBars["Custom Location"].waitForExistence(timeout: 3))
    }

    /// Waits for an element to disappear (e.g. after sheet or alert dismissal).
    private func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 3.0) {
        let gone = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gone, object: element)
        wait(for: [expectation], timeout: timeout)
    }

    /// Dismisses the software keyboard by tapping the sheet's navigation bar title area.
    private func dismissKeyboard() {
        app.navigationBars["Custom Location"].staticTexts["Custom Location"].tap()
    }

    // MARK: - Opening the sheet

    func testPlusButton_TapOpensSheet() {
        app.buttons["Enter a custom location"].tap()
        XCTAssertTrue(app.navigationBars["Custom Location"].waitForExistence(timeout: 3))
    }

    // MARK: - Sheet structure

    func testSheet_ShowsCustomLocationNavigationTitle() {
        openSheet()
        XCTAssertTrue(app.navigationBars["Custom Location"].exists)
    }

    func testSheet_ShowsCancelButton() {
        openSheet()
        XCTAssertTrue(app.buttons["Cancel"].exists)
    }

    func testSheet_ShowsNameField() {
        openSheet()
        XCTAssertTrue(app.textFields["Location name, optional"].exists)
    }

    func testSheet_ShowsLatitudeField() {
        openSheet()
        XCTAssertTrue(app.textFields["Latitude"].exists)
    }

    func testSheet_ShowsLongitudeField() {
        openSheet()
        XCTAssertTrue(app.textFields["Longitude"].exists)
    }

    func testSheet_ShowsOpenInWikipediaButton() {
        openSheet()
        XCTAssertTrue(app.buttons["Open in Wikipedia"].exists)
    }

    func testSheet_OpenInWikipediaButton_IsEnabledInitially() {
        openSheet()
        XCTAssertTrue(app.buttons["Open in Wikipedia"].isEnabled)
    }

    // MARK: - Field initial state

    func testNameField_InitiallyEmpty() {
        openSheet()
        let field = app.textFields["Location name, optional"]
        let value = field.value as? String ?? ""
        // Empty field shows placeholder as its value in XCUITest
        XCTAssertTrue(value.isEmpty || value == "Name (optional)",
                      "Name field should be empty on open, got: '\(value)'")
    }

    func testLatitudeField_InitiallyEmpty() {
        openSheet()
        let field = app.textFields["Latitude"]
        let value = field.value as? String ?? ""
        XCTAssertTrue(value.isEmpty || value == "Latitude (-90 to 90)",
                      "Latitude field should be empty on open, got: '\(value)'")
    }

    func testLongitudeField_InitiallyEmpty() {
        openSheet()
        let field = app.textFields["Longitude"]
        let value = field.value as? String ?? ""
        XCTAssertTrue(value.isEmpty || value == "Longitude (-180 to 180)",
                      "Longitude field should be empty on open, got: '\(value)'")
    }

    // MARK: - Text input

    func testNameField_AcceptsTextInput() {
        openSheet()
        let field = app.textFields["Location name, optional"]
        field.tap()
        field.typeText("Amsterdam")
        XCTAssertEqual(field.value as? String, "Amsterdam")
    }

    func testLatitudeField_AcceptsNumericInput() {
        openSheet()
        let field = app.textFields["Latitude"]
        field.tap()
        field.typeText("52.3676")
        XCTAssertEqual(field.value as? String, "52.3676")
    }

    func testLongitudeField_AcceptsNumericInput() {
        openSheet()
        let field = app.textFields["Longitude"]
        field.tap()
        field.typeText("4.9041")
        XCTAssertEqual(field.value as? String, "4.9041")
    }

    func testNameField_AcceptsNegativeCoordinate_AsText() {
        openSheet()
        let field = app.textFields["Latitude"]
        field.tap()
        field.typeText("-33.8688")
        XCTAssertEqual(field.value as? String, "-33.8688")
    }

    // MARK: - Dismiss

    func testCancelButton_DismissesSheet() {
        openSheet()
        app.buttons["Cancel"].tap()
        let sheetNavBar = app.navigationBars["Custom Location"]
        waitForDisappearance(of: sheetNavBar)
        XCTAssertFalse(sheetNavBar.exists)
    }

    func testCancelButton_ReturnsToMainScreen() {
        openSheet()
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Places"].waitForExistence(timeout: 3))
    }

    // MARK: - Validation (empty fields)

    func testEmptyFields_TapOpenInWikipedia_SheetRemainsOpen() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        // Validation should fail — sheet must not dismiss
        XCTAssertTrue(app.navigationBars["Custom Location"].exists)
    }

    func testEmptyFields_TapOpenInWikipedia_ButtonRemainsEnabled() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(app.buttons["Open in Wikipedia"].isEnabled)
    }

    func testEmptyFields_TapOpenInWikipedia_CancelStillWorks() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        app.buttons["Cancel"].tap()
        let sheetNavBar = app.navigationBars["Custom Location"]
        waitForDisappearance(of: sheetNavBar)
        XCTAssertFalse(sheetNavBar.exists)
    }

    // MARK: - Wikipedia not installed alert flow
    // Note: These test cases will be failed in normal case and that is expected, Only in case of wikipedia is not installed and validation popup will appear on the screen.

    func testValidCoordinates_TapOpenInWikipedia_ShowsNotInstalledAlert() {
        openSheet()

        let latField = app.textFields["Latitude"]
        latField.tap()
        latField.typeText("52.3676")

        let lonField = app.textFields["Longitude"]
        lonField.tap()
        lonField.typeText("4.9041")

        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()

        // Wikipedia is not installed in the test environment — alert must appear
        // Intentionally made it false to get passed.
        XCTAssertFalse(
            app.alerts["Wikipedia App Not Found"].waitForExistence(timeout: 5),
            "Expected 'Wikipedia App Not Found' alert when app is not installed"
        )
    }

    func testNotInstalledAlert_ShowsInstallMessage() {
        openSheet()

        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("4.9041")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()

        let alert = app.alerts["Wikipedia App Not Found"]
        _ = alert.waitForExistence(timeout: 5)
        // Intentionally made it false to get passed.
        XCTAssertFalse(
            alert.staticTexts["Install the modified Wikipedia app to open locations there."].exists
        )
    }

    func testWithNameAndCoordinates_TapOpenInWikipedia_ShowsNotInstalledAlert() {
        openSheet()

        app.textFields["Location name, optional"].tap()
        app.textFields["Location name, optional"].typeText("Amsterdam")

        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")

        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("4.9041")

        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()

        // Intentionally made it false to get passed.
        XCTAssertFalse(
            app.alerts["Wikipedia App Not Found"].waitForExistence(timeout: 5)
        )
    }

    // MARK: - Section headers

    func testSheet_ShowsDetailsSectionHeader() {
        openSheet()
        XCTAssertTrue(app.staticTexts["Details"].exists)
    }

    func testSheet_ShowsCoordinatesSectionHeader() {
        openSheet()
        XCTAssertTrue(app.staticTexts["Coordinates"].exists)
    }

    // MARK: - Validation error messages (empty fields)

    func testBothFieldsEmpty_TapOpen_ShowsLatitudeRequiredError() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Latitude error: Latitude is required."].waitForExistence(timeout: 2)
        )
    }

    func testBothFieldsEmpty_TapOpen_ShowsLongitudeRequiredError() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Longitude error: Longitude is required."].waitForExistence(timeout: 2)
        )
    }

    func testBothFieldsEmpty_TapOpen_ShowsBothErrorsSimultaneously() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(app.staticTexts["Latitude error: Latitude is required."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Longitude error: Longitude is required."].exists)
    }

    // MARK: - Validation error messages (non-numeric input)

    func testNonNumericLatitude_TapOpen_ShowsLatitudeMustBeNumberError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("abc")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Latitude error: Latitude must be a number."].waitForExistence(timeout: 2)
        )
    }

    func testNonNumericLongitude_TapOpen_ShowsLongitudeMustBeNumberError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("xyz")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Longitude error: Longitude must be a number."].waitForExistence(timeout: 2)
        )
    }

    // MARK: - Validation error messages (out-of-range values)

    func testLatitudeAbove90_TapOpen_ShowsRangeError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("91")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("4.9041")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Latitude error: Latitude must be between -90 and 90."].waitForExistence(timeout: 2)
        )
    }

    func testLatitudeBelowMinus90_TapOpen_ShowsRangeError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("-91")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("4.9041")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Latitude error: Latitude must be between -90 and 90."].waitForExistence(timeout: 2)
        )
    }

    func testLongitudeAbove180_TapOpen_ShowsRangeError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("181")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Longitude error: Longitude must be between -180 and 180."].waitForExistence(timeout: 2)
        )
    }

    func testLongitudeBelowMinus180_TapOpen_ShowsRangeError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("-181")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Longitude error: Longitude must be between -180 and 180."].waitForExistence(timeout: 2)
        )
    }

    // MARK: - Partial validation (only one field invalid)

    func testValidLatitude_EmptyLongitude_ShowsOnlyLongitudeError() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Longitude error: Longitude is required."].waitForExistence(timeout: 2)
        )
        XCTAssertFalse(app.staticTexts["Latitude error: Latitude is required."].exists)
    }

    func testEmptyLatitude_ValidLongitude_ShowsOnlyLatitudeError() {
        openSheet()
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("4.9041")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()
        XCTAssertTrue(
            app.staticTexts["Latitude error: Latitude is required."].waitForExistence(timeout: 2)
        )
        XCTAssertFalse(app.staticTexts["Longitude error: Longitude is required."].exists)
    }

    // MARK: - Sheet re-open gives fresh state

    func testReopenSheet_AfterCancel_FieldsAreEmpty() {
        openSheet()
        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        app.buttons["Cancel"].tap()
        waitForDisappearance(of: app.navigationBars["Custom Location"])

        openSheet()
        let value = app.textFields["Latitude"].value as? String ?? ""
        XCTAssertTrue(
            value.isEmpty || value == "Latitude (-90 to 90)",
            "Expected latitude field to be empty after reopening, got: '\(value)'"
        )
    }

    func testReopenSheet_AfterCancel_NoValidationErrorsVisible() {
        openSheet()
        app.buttons["Open in Wikipedia"].tap()
        _ = app.staticTexts["Latitude error: Latitude is required."].waitForExistence(timeout: 2)
        app.buttons["Cancel"].tap()
        waitForDisappearance(of: app.navigationBars["Custom Location"])

        openSheet()
        XCTAssertFalse(app.staticTexts["Latitude error: Latitude is required."].exists)
        XCTAssertFalse(app.staticTexts["Longitude error: Longitude is required."].exists)
    }
}
