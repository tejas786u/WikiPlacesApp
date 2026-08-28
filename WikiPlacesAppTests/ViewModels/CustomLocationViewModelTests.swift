//
//  CustomLocationViewModelTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class CustomLocationViewModelTests: XCTestCase {

    private func makeSUT() -> CustomLocationViewModel {
        CustomLocationViewModel()
    }

    // MARK: - Initial State

    func testInitialState_AllFieldsEmpty() {
        let sut = makeSUT()
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.latitudeText, "")
        XCTAssertEqual(sut.longitudeText, "")
        XCTAssertNil(sut.latitudeError)
        XCTAssertNil(sut.longitudeError)
    }

    func testInitialState_ValidatedCoordinateReturnsNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.validatedCoordinate())
    }

    // MARK: - Empty field validation

    func testValidatedCoordinate_BothFieldsEmpty_SetsBothErrors() {
        let sut = makeSUT()
        let result = sut.validatedCoordinate()
        XCTAssertNil(result)
        XCTAssertNotNil(sut.latitudeError)
        XCTAssertNotNil(sut.longitudeError)
    }

    func testValidatedCoordinate_EmptyLatitude_SetsLatitudeError() {
        let sut = makeSUT()
        sut.longitudeText = "10"
        let result = sut.validatedCoordinate()
        XCTAssertNil(result)
        XCTAssertNotNil(sut.latitudeError)
        XCTAssertNil(sut.longitudeError)
    }

    func testValidatedCoordinate_EmptyLongitude_SetsLongitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "10"
        let result = sut.validatedCoordinate()
        XCTAssertNil(result)
        XCTAssertNil(sut.latitudeError)
        XCTAssertNotNil(sut.longitudeError)
    }

    // MARK: - Non-numeric input

    func testValidatedCoordinate_NonNumericLatitude_SetsLatitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "abc"
        sut.longitudeText = "10"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNotNil(sut.latitudeError)
        XCTAssertNil(sut.longitudeError)
    }

    func testValidatedCoordinate_NonNumericLongitude_SetsLongitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "10"
        sut.longitudeText = "xyz"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNil(sut.latitudeError)
        XCTAssertNotNil(sut.longitudeError)
    }

    func testValidatedCoordinate_BothFieldsNonNumeric_SetsBothErrors() {
        let sut = makeSUT()
        sut.latitudeText = "abc"
        sut.longitudeText = "xyz"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNotNil(sut.latitudeError)
        XCTAssertNotNil(sut.longitudeError)
    }

    // MARK: - Out-of-range values

    func testValidatedCoordinate_LatitudeAbove90_SetsLatitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "91"
        sut.longitudeText = "0"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNotNil(sut.latitudeError)
    }

    func testValidatedCoordinate_LatitudeBelowMinus90_SetsLatitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "-91"
        sut.longitudeText = "0"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNotNil(sut.latitudeError)
    }

    func testValidatedCoordinate_LongitudeAbove180_SetsLongitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "0"
        sut.longitudeText = "181"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNotNil(sut.longitudeError)
    }

    func testValidatedCoordinate_LongitudeBelowMinus180_SetsLongitudeError() {
        let sut = makeSUT()
        sut.latitudeText = "0"
        sut.longitudeText = "-181"
        XCTAssertNil(sut.validatedCoordinate())
        XCTAssertNotNil(sut.longitudeError)
    }

    // MARK: - Boundary values (inclusive range)

    func testValidatedCoordinate_LatitudeExactly90_Succeeds() {
        let sut = makeSUT()
        sut.latitudeText = "90"
        sut.longitudeText = "0"
        XCTAssertNotNil(sut.validatedCoordinate())
        XCTAssertNil(sut.latitudeError)
    }

    func testValidatedCoordinate_LatitudeExactlyMinus90_Succeeds() {
        let sut = makeSUT()
        sut.latitudeText = "-90"
        sut.longitudeText = "0"
        XCTAssertNotNil(sut.validatedCoordinate())
        XCTAssertNil(sut.latitudeError)
    }

    func testValidatedCoordinate_LongitudeExactly180_Succeeds() {
        let sut = makeSUT()
        sut.latitudeText = "0"
        sut.longitudeText = "180"
        XCTAssertNotNil(sut.validatedCoordinate())
        XCTAssertNil(sut.longitudeError)
    }

    func testValidatedCoordinate_LongitudeExactlyMinus180_Succeeds() {
        let sut = makeSUT()
        sut.latitudeText = "0"
        sut.longitudeText = "-180"
        XCTAssertNotNil(sut.validatedCoordinate())
        XCTAssertNil(sut.longitudeError)
    }

    // MARK: - Valid input

    func testValidatedCoordinate_ValidInput_ReturnsLocationWithCorrectCoordinates() throws {
        let sut = makeSUT()
        sut.latitudeText = "52.3676"
        sut.longitudeText = "4.9041"
        let result = try XCTUnwrap(sut.validatedCoordinate())
        XCTAssertEqual(result.latitude, 52.3676, accuracy: 0.00001)
        XCTAssertEqual(result.longitude, 4.9041, accuracy: 0.00001)
        XCTAssertNil(sut.latitudeError)
        XCTAssertNil(sut.longitudeError)
    }

    func testValidatedCoordinate_ZeroCoordinates_Succeeds() {
        let sut = makeSUT()
        sut.latitudeText = "0"
        sut.longitudeText = "0"
        let result = sut.validatedCoordinate()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.latitude, 0)
        XCTAssertEqual(result?.longitude, 0)
    }

    func testValidatedCoordinate_NegativeCoordinates_Succeeds() throws {
        let sut = makeSUT()
        sut.latitudeText = "-33.8688"
        sut.longitudeText = "-70.6693"
        let result = sut.validatedCoordinate()
        let unwrapped = try XCTUnwrap(result)
        XCTAssertEqual(unwrapped.latitude, -33.8688, accuracy: 0.00001)
        XCTAssertEqual(unwrapped.longitude, -70.6693, accuracy: 0.00001)
    }

    // MARK: - Name handling

    func testValidatedCoordinate_WithName_ReturnsLocationWithName() {
        let sut = makeSUT()
        sut.name = "Amsterdam"
        sut.latitudeText = "52.3676"
        sut.longitudeText = "4.9041"
        let result = sut.validatedCoordinate()
        XCTAssertEqual(result?.name, "Amsterdam")
    }

    func testValidatedCoordinate_WithNilEquivalentEmptyName_ReturnsNilName() {
        let sut = makeSUT()
        sut.name = ""
        sut.latitudeText = "0"
        sut.longitudeText = "0"
        XCTAssertNil(sut.validatedCoordinate()?.name)
    }

    func testValidatedCoordinate_NameOnlyWhitespace_ReturnsNilName() {
        let sut = makeSUT()
        sut.name = "   "
        sut.latitudeText = "0"
        sut.longitudeText = "0"
        XCTAssertNil(sut.validatedCoordinate()?.name)
    }

    func testValidatedCoordinate_NameWithLeadingTrailingSpaces_ReturnsTrimmedName() {
        let sut = makeSUT()
        sut.name = "  Paris  "
        sut.latitudeText = "48.8566"
        sut.longitudeText = "2.3522"
        XCTAssertEqual(sut.validatedCoordinate()?.name, "Paris")
    }

    // MARK: - Whitespace in coordinate input

    func testValidatedCoordinate_CoordinatesWithLeadingTrailingWhitespace_Succeeds() {
        let sut = makeSUT()
        sut.latitudeText = "  45  "
        sut.longitudeText = "  90  "
        XCTAssertNotNil(sut.validatedCoordinate())
    }

    // MARK: - Re-validation clears errors

    func testValidatedCoordinate_AfterLatitudeError_ValidInputClearsError() {
        let sut = makeSUT()
        sut.latitudeText = "invalid"
        sut.longitudeText = "0"
        sut.validatedCoordinate()
        XCTAssertNotNil(sut.latitudeError)

        sut.latitudeText = "45"
        sut.validatedCoordinate()
        XCTAssertNil(sut.latitudeError)
    }

    func testValidatedCoordinate_AfterLongitudeError_ValidInputClearsError() {
        let sut = makeSUT()
        sut.latitudeText = "0"
        sut.longitudeText = "999"
        sut.validatedCoordinate()
        XCTAssertNotNil(sut.longitudeError)

        sut.longitudeText = "45"
        sut.validatedCoordinate()
        XCTAssertNil(sut.longitudeError)
    }

    func testValidatedCoordinate_ValidThenInvalid_ErrorReappears() {
        let sut = makeSUT()
        sut.latitudeText = "45"
        sut.longitudeText = "90"
        sut.validatedCoordinate()
        XCTAssertNil(sut.latitudeError)

        sut.latitudeText = "999"
        sut.validatedCoordinate()
        XCTAssertNotNil(sut.latitudeError)
    }

    // MARK: - Return value is discardable

    func testValidatedCoordinate_DiscardableResult_SetsErrorsSideEffect() {
        let sut = makeSUT()
        sut.latitudeText = "invalid"
        sut.longitudeText = "invalid"
        sut.validatedCoordinate() // discarding result — side effects still apply
        XCTAssertNotNil(sut.latitudeError)
        XCTAssertNotNil(sut.longitudeError)
    }
}
