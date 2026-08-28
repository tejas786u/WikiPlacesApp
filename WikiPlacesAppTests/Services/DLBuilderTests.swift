//
//  DLBuilderTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest
@testable import WikiPlacesApp

final class DLBuilderTests: XCTestCase {

    private let sut = WikipediaDeepLink()

    // MARK: - Helpers

    private func makeLocation(
        name: String? = "Amsterdam",
        lat: Double = 52.3676,
        lon: Double = 4.9041
    ) -> Location {
        Location(name: name, latitude: lat, longitude: lon)
    }

    private func queryItems(for location: Location) -> [URLQueryItem] {
        guard let url = sut.createDeepLink(for: location),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return []
        }
        return components.queryItems ?? []
    }

    private func queryValue(named name: String, for location: Location) -> String? {
        queryItems(for: location).first { $0.name == name }?.value
    }

    // MARK: - URL structure

    func testCreateDeepLink_HasWikipediaScheme() {
        let url = sut.createDeepLink(for: makeLocation())
        XCTAssertEqual(url?.scheme, "wikipedia")
    }

    func testCreateDeepLink_HasPlacesHost() {
        let url = sut.createDeepLink(for: makeLocation())
        XCTAssertEqual(url?.host, "places")
    }

    func testCreateDeepLink_ReturnsNonNilURL() {
        XCTAssertNotNil(sut.createDeepLink(for: makeLocation()))
    }

    // MARK: - Latitude parameter

    func testCreateDeepLink_ContainsLatitudeParam() {
        XCTAssertNotNil(queryValue(named: "lat", for: makeLocation()))
    }

    func testCreateDeepLink_LatitudeParamHasCorrectValue() {
        XCTAssertEqual(queryValue(named: "lat", for: makeLocation(lat: 52.3676)), "52.3676")
    }

    func testCreateDeepLink_NegativeLatitude_EncodesCorrectly() {
        XCTAssertEqual(queryValue(named: "lat", for: makeLocation(lat: -33.8688)), "-33.8688")
    }

    func testCreateDeepLink_ZeroLatitude_EncodesCorrectly() {
        XCTAssertEqual(queryValue(named: "lat", for: makeLocation(lat: 0)), "0.0")
    }

    func testCreateDeepLink_BoundaryLatitude90_EncodesCorrectly() {
        XCTAssertEqual(queryValue(named: "lat", for: makeLocation(lat: 90)), "90.0")
    }

    // MARK: - Longitude parameter

    func testCreateDeepLink_ContainsLongitudeParam() {
        XCTAssertNotNil(queryValue(named: "lon", for: makeLocation()))
    }

    func testCreateDeepLink_LongitudeParamHasCorrectValue() {
        XCTAssertEqual(queryValue(named: "lon", for: makeLocation(lon: 4.9041)), "4.9041")
    }

    func testCreateDeepLink_NegativeLongitude_EncodesCorrectly() {
        XCTAssertEqual(queryValue(named: "lon", for: makeLocation(lon: -70.6693)), "-70.6693")
    }

    func testCreateDeepLink_BoundaryLongitude180_EncodesCorrectly() {
        XCTAssertEqual(queryValue(named: "lon", for: makeLocation(lon: 180)), "180.0")
    }

    // MARK: - Name parameter

    func testCreateDeepLink_WithName_IncludesNameParam() {
        XCTAssertEqual(queryValue(named: "name", for: makeLocation(name: "Amsterdam")), "Amsterdam")
    }

    func testCreateDeepLink_WithNilName_OmitsNameParam() {
        let items = queryItems(for: makeLocation(name: nil))
        XCTAssertNil(items.first { $0.name == "name" })
    }

    func testCreateDeepLink_WithEmptyName_OmitsNameParam() {
        let items = queryItems(for: makeLocation(name: ""))
        XCTAssertNil(items.first { $0.name == "name" })
    }

    func testCreateDeepLink_WithWhitespaceOnlyName_OmitsNameParam() {
        let items = queryItems(for: makeLocation(name: "   "))
        XCTAssertNil(items.first { $0.name == "name" })
    }

    func testCreateDeepLink_NameWithLeadingTrailingWhitespace_TrimsName() {
        XCTAssertEqual(queryValue(named: "name", for: makeLocation(name: "  Paris  ")), "Paris")
    }

    func testCreateDeepLink_NameWithSpaces_PreservesInternalSpaces() {
        XCTAssertEqual(
            queryValue(named: "name", for: makeLocation(name: "New York")),
            "New York"
        )
    }

    // MARK: - Query item count

    func testCreateDeepLink_WithName_HasThreeQueryItems() {
        XCTAssertEqual(queryItems(for: makeLocation(name: "Paris")).count, 3)
    }

    func testCreateDeepLink_WithoutName_HasTwoQueryItems() {
        XCTAssertEqual(queryItems(for: makeLocation(name: nil)).count, 2)
    }

    func testCreateDeepLink_WithEmptyName_HasTwoQueryItems() {
        XCTAssertEqual(queryItems(for: makeLocation(name: "")).count, 2)
    }

    // MARK: - Query item order

    func testCreateDeepLink_LatitudeIsFirstQueryItem() {
        let items = queryItems(for: makeLocation())
        XCTAssertEqual(items.first?.name, "lat")
    }

    func testCreateDeepLink_LongitudeIsSecondQueryItem() {
        let items = queryItems(for: makeLocation())
        XCTAssertEqual(items.dropFirst().first?.name, "lon")
    }

    func testCreateDeepLink_NameIsLastQueryItem_WhenPresent() {
        let items = queryItems(for: makeLocation(name: "Amsterdam"))
        XCTAssertEqual(items.last?.name, "name")
    }
}
