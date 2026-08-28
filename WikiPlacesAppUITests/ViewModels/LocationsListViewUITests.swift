//
//  LocationsListViewUITests.swift
//  WikiPlacesAppUITests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest

final class LocationsListViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation Bar

    func testNavigationBar_ShowsPlacesTitle() {
        XCTAssertTrue(app.navigationBars["Places"].waitForExistence(timeout: 3))
    }

    func testNavigationBar_CustomLocationButtonExists() {
        XCTAssertTrue(app.buttons["Enter a custom location"].waitForExistence(timeout: 3))
    }

    func testNavigationBar_CustomLocationButtonIsEnabled() {
        let button = app.buttons["Enter a custom location"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        XCTAssertTrue(button.isEnabled)
    }

    func testNavigationBar_CustomLocationButtonIsHittable() {
        let button = app.buttons["Enter a custom location"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        XCTAssertTrue(button.isHittable)
    }

    // MARK: - Content

    func testMainScreen_ShowsScrollableContent() {
        XCTAssertTrue(app.scrollViews.firstMatch.waitForExistence(timeout: 3))
    }

    func testMainScreen_EventuallyShowsLocationsOrStatusView() {
        // After network resolves, one of these will appear:
        // - Location cards (buttons with accessibility hint "Opens this location in Wikipedia")
        // - Empty state
        // - Error state
        let emptyState = app.staticTexts["No Locations Found"]
        let errorState = app.staticTexts["Something went wrong"]
        let locationButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Wikipedia'")
        ).firstMatch

        // Give network time to resolve; at least one should appear
        let appeared = emptyState.waitForExistence(timeout: 15)
            || errorState.exists
            || locationButton.exists

        XCTAssertTrue(appeared, "Expected locations, empty state, or error state to appear after loading")
    }

    func testErrorState_WhenShown_HasRetryButton() {
        let errorTitle = app.staticTexts["Something went wrong"]
        guard errorTitle.waitForExistence(timeout: 15) else { return }
        XCTAssertTrue(app.buttons["Try Again"].exists)
    }

    func testEmptyState_WhenShown_HasRefreshButton() {
        let emptyTitle = app.staticTexts["No Locations Found"]
        guard emptyTitle.waitForExistence(timeout: 15) else { return }
        XCTAssertTrue(app.buttons["Refresh"].exists)
    }
}
