//
//  CustomLocationInteractorTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 02/09/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class CustomLocationInteractorTests: XCTestCase {

    private func makeSUT(openerSucceeds: Bool = true) -> (sut: CustomLocationInteractor, deepLinkWorker: MockDeepLinkWorker, presenter: MockCustomLocationPresenter) {
        let deepLinkWorker = MockDeepLinkWorker()
        deepLinkWorker.shouldSucceed = openerSucceeds
        let presenter = MockCustomLocationPresenter()
        let sut = CustomLocationInteractor(deepLinkWorker: deepLinkWorker)
        sut.presenter = presenter
        return (sut, deepLinkWorker, presenter)
    }

    private func validate(_ sut: CustomLocationInteractor, name: String = "", lat: String = "", lon: String = "") {
        sut.validate(request: CustomLocation.Validate.Request(name: name, latitudeText: lat, longitudeText: lon))
    }

    // MARK: - Initial State

    func testInitialState_ValidatedLocationIsNil() {
        let (sut, _, _) = makeSUT()
        XCTAssertNil(sut.validatedLocation)
    }

    // MARK: - Empty field validation

    func testValidate_BothFieldsEmpty_SetsBothErrors() {
        let (sut, _, presenter) = makeSUT()
        validate(sut)
        let response = presenter.validationResponses.last
        XCTAssertNotNil(response?.latitudeError)
        XCTAssertNotNil(response?.longitudeError)
        XCTAssertNil(sut.validatedLocation)
    }

    func testValidate_EmptyLatitude_SetsLatitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lon: "10")
        let response = presenter.validationResponses.last
        XCTAssertNotNil(response?.latitudeError)
        XCTAssertNil(response?.longitudeError)
    }

    func testValidate_EmptyLongitude_SetsLongitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "10")
        let response = presenter.validationResponses.last
        XCTAssertNil(response?.latitudeError)
        XCTAssertNotNil(response?.longitudeError)
    }

    // MARK: - Non-numeric input

    func testValidate_NonNumericLatitude_SetsLatitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "abc", lon: "10")
        let response = presenter.validationResponses.last
        XCTAssertNotNil(response?.latitudeError)
        XCTAssertNil(response?.longitudeError)
        XCTAssertNil(sut.validatedLocation)
    }

    func testValidate_NonNumericLongitude_SetsLongitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "10", lon: "xyz")
        let response = presenter.validationResponses.last
        XCTAssertNil(response?.latitudeError)
        XCTAssertNotNil(response?.longitudeError)
    }

    // MARK: - Out-of-range values

    func testValidate_LatitudeAbove90_SetsLatitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "91", lon: "0")
        XCTAssertNotNil(presenter.validationResponses.last?.latitudeError)
        XCTAssertNil(sut.validatedLocation)
    }

    func testValidate_LatitudeBelowMinus90_SetsLatitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "-91", lon: "0")
        XCTAssertNotNil(presenter.validationResponses.last?.latitudeError)
    }

    func testValidate_LongitudeAbove180_SetsLongitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "0", lon: "181")
        XCTAssertNotNil(presenter.validationResponses.last?.longitudeError)
    }

    func testValidate_LongitudeBelowMinus180_SetsLongitudeError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "0", lon: "-181")
        XCTAssertNotNil(presenter.validationResponses.last?.longitudeError)
    }

    // MARK: - Boundary values (inclusive range)

    func testValidate_LatitudeExactly90_Succeeds() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "90", lon: "0")
        XCTAssertNil(presenter.validationResponses.last?.latitudeError)
        XCTAssertNotNil(sut.validatedLocation)
    }

    func testValidate_LatitudeExactlyMinus90_Succeeds() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "-90", lon: "0")
        XCTAssertNil(presenter.validationResponses.last?.latitudeError)
    }

    func testValidate_LongitudeExactly180_Succeeds() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "0", lon: "180")
        XCTAssertNil(presenter.validationResponses.last?.longitudeError)
    }

    func testValidate_LongitudeExactlyMinus180_Succeeds() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "0", lon: "-180")
        XCTAssertNil(presenter.validationResponses.last?.longitudeError)
    }

    // MARK: - Valid input

    func testValidate_ValidInput_StoresLocationWithCorrectCoordinates() throws {
        let (sut, _, _) = makeSUT()
        validate(sut, lat: "52.3676", lon: "4.9041")
        let result = try XCTUnwrap(sut.validatedLocation)
        XCTAssertEqual(result.latitude, 52.3676, accuracy: 0.00001)
        XCTAssertEqual(result.longitude, 4.9041, accuracy: 0.00001)
    }

    func testValidate_ZeroCoordinates_Succeeds() {
        let (sut, _, _) = makeSUT()
        validate(sut, lat: "0", lon: "0")
        XCTAssertNotNil(sut.validatedLocation)
        XCTAssertEqual(sut.validatedLocation?.latitude, 0)
        XCTAssertEqual(sut.validatedLocation?.longitude, 0)
    }

    func testValidate_NegativeCoordinates_Succeeds() throws {
        let (sut, _, _) = makeSUT()
        validate(sut, lat: "-33.8688", lon: "-70.6693")
        let result = try XCTUnwrap(sut.validatedLocation)
        XCTAssertEqual(result.latitude, -33.8688, accuracy: 0.00001)
        XCTAssertEqual(result.longitude, -70.6693, accuracy: 0.00001)
    }

    // MARK: - Name handling

    func testValidate_WithName_StoresLocationWithName() {
        let (sut, _, _) = makeSUT()
        validate(sut, name: "Amsterdam", lat: "52.3676", lon: "4.9041")
        XCTAssertEqual(sut.validatedLocation?.name, "Amsterdam")
    }

    func testValidate_WithEmptyName_StoresNilName() {
        let (sut, _, _) = makeSUT()
        validate(sut, name: "", lat: "0", lon: "0")
        XCTAssertNil(sut.validatedLocation?.name)
    }

    func testValidate_NameOnlyWhitespace_StoresNilName() {
        let (sut, _, _) = makeSUT()
        validate(sut, name: "   ", lat: "0", lon: "0")
        XCTAssertNil(sut.validatedLocation?.name)
    }

    func testValidate_NameWithLeadingTrailingSpaces_StoresTrimmedName() {
        let (sut, _, _) = makeSUT()
        validate(sut, name: "  Paris  ", lat: "48.8566", lon: "2.3522")
        XCTAssertEqual(sut.validatedLocation?.name, "Paris")
    }

    // MARK: - Whitespace in coordinate input

    func testValidate_CoordinatesWithLeadingTrailingWhitespace_Succeeds() {
        let (sut, _, _) = makeSUT()
        validate(sut, lat: "  45  ", lon: "  90  ")
        XCTAssertNotNil(sut.validatedLocation)
    }

    // MARK: - Re-validation clears errors

    func testValidate_AfterLatitudeError_ValidInputClearsError() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "invalid", lon: "0")
        XCTAssertNotNil(presenter.validationResponses.last?.latitudeError)

        validate(sut, lat: "45", lon: "0")
        XCTAssertNil(presenter.validationResponses.last?.latitudeError)
    }

    func testValidate_ValidThenInvalid_ErrorReappears() {
        let (sut, _, presenter) = makeSUT()
        validate(sut, lat: "45", lon: "90")
        XCTAssertNil(presenter.validationResponses.last?.latitudeError)

        validate(sut, lat: "999", lon: "90")
        XCTAssertNotNil(presenter.validationResponses.last?.latitudeError)
        XCTAssertNil(sut.validatedLocation)
    }

    // MARK: - open

    func testOpen_WithoutValidating_DoesNothing() async {
        let (sut, deepLinkWorker, presenter) = makeSUT()
        await sut.open(request: CustomLocation.Open.Request())
        XCTAssertEqual(deepLinkWorker.openCallCount, 0)
        XCTAssertTrue(presenter.openResponses.isEmpty)
    }

    func testOpen_AfterValidInput_CallsWorkerWithValidatedLocation() async {
        let (sut, deepLinkWorker, _) = makeSUT()
        validate(sut, name: "Amsterdam", lat: "52.3676", lon: "4.9041")

        await sut.open(request: CustomLocation.Open.Request())

        XCTAssertEqual(deepLinkWorker.lastOpenedLocation?.name, "Amsterdam")
        XCTAssertEqual(deepLinkWorker.openCallCount, 1)
    }

    func testOpen_Success_ReportsSuccess() async {
        let (sut, _, presenter) = makeSUT(openerSucceeds: true)
        validate(sut, lat: "0", lon: "0")

        await sut.open(request: CustomLocation.Open.Request())

        XCTAssertEqual(presenter.openResponses.last?.success, true)
    }

    func testOpen_Failure_ReportsFailure() async {
        let (sut, _, presenter) = makeSUT(openerSucceeds: false)
        validate(sut, lat: "0", lon: "0")

        await sut.open(request: CustomLocation.Open.Request())

        XCTAssertEqual(presenter.openResponses.last?.success, false)
    }
}
