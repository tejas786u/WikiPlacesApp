//
//  CustomLocationPresenterTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 02/09/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class CustomLocationPresenterTests: XCTestCase {

    private func makeSUT() -> CustomLocationPresenter {
        CustomLocationPresenter()
    }

    // MARK: - Initial State

    func testInitialState_NoErrors() {
        let sut = makeSUT()
        XCTAssertNil(sut.latitudeError)
        XCTAssertNil(sut.longitudeError)
        XCTAssertFalse(sut.isShowingNotInstalledAlert)
        XCTAssertTrue(sut.isValid)
    }

    // MARK: - presentValidation

    func testPresentValidation_WithErrors_SetsErrorsAndInvalid() {
        let sut = makeSUT()

        sut.presentValidation(response: CustomLocation.Validate.Response(
            latitudeError: "Latitude is required.",
            longitudeError: "Longitude is required."
        ))

        XCTAssertEqual(sut.latitudeError, "Latitude is required.")
        XCTAssertEqual(sut.longitudeError, "Longitude is required.")
        XCTAssertFalse(sut.isValid)
    }

    func testPresentValidation_NoErrors_IsValid() {
        let sut = makeSUT()

        sut.presentValidation(response: CustomLocation.Validate.Response(latitudeError: nil, longitudeError: nil))

        XCTAssertTrue(sut.isValid)
    }

    func testPresentValidation_OnlyLatitudeError_IsInvalid() {
        let sut = makeSUT()

        sut.presentValidation(response: CustomLocation.Validate.Response(latitudeError: "bad", longitudeError: nil))

        XCTAssertFalse(sut.isValid)
    }

    func testPresentValidation_ClearsExistingErrors() {
        let sut = makeSUT()
        sut.presentValidation(response: CustomLocation.Validate.Response(latitudeError: "bad", longitudeError: "bad"))
        XCTAssertFalse(sut.isValid)

        sut.presentValidation(response: CustomLocation.Validate.Response(latitudeError: nil, longitudeError: nil))
        XCTAssertTrue(sut.isValid)
    }

    // MARK: - presentOpenResult

    func testPresentOpenResult_Success_DoesNotShowAlert() {
        let sut = makeSUT()
        sut.presentOpenResult(response: CustomLocation.Open.Response(success: true))
        XCTAssertFalse(sut.isShowingNotInstalledAlert)
    }

    func testPresentOpenResult_Failure_ShowsAlert() {
        let sut = makeSUT()
        sut.presentOpenResult(response: CustomLocation.Open.Response(success: false))
        XCTAssertTrue(sut.isShowingNotInstalledAlert)
    }
}
