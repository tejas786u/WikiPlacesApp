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
        XCTAssertTrue(
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
        XCTAssertTrue(
            alert.staticTexts["Install the modified Wikipedia app to open locations there."].exists
        )
    }

    func testNotInstalledAlert_TapOK_DismissesAlert() {
        openSheet()

        app.textFields["Latitude"].tap()
        app.textFields["Latitude"].typeText("52.3676")
        app.textFields["Longitude"].tap()
        app.textFields["Longitude"].typeText("4.9041")
        dismissKeyboard()
        app.buttons["Open in Wikipedia"].tap()

        let alert = app.alerts["Wikipedia App Not Found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()

        waitForDisappearance(of: alert)
        XCTAssertFalse(alert.exists)
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

        XCTAssertTrue(
            app.alerts["Wikipedia App Not Found"].waitForExistence(timeout: 5)
        )
    }
}
