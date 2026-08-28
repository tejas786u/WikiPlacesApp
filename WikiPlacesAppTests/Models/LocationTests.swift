//
//  LocationTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class LocationTests: XCTestCase {

    // MARK: - displayName

    func testDisplayName_WithName_ReturnsName() {
        let location = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        XCTAssertEqual(location.displayName, "Amsterdam")
    }

    func testDisplayName_WithNilName_ReturnsCoordinateString() {
        let location = Location(name: nil, latitude: 52.3676, longitude: 4.9041)
        XCTAssertEqual(location.displayName, Location.coordinateString(latitude: 52.3676, longitude: 4.9041))
    }

    func testDisplayName_WithEmptyName_ReturnsCoordinateString() {
        let location = Location(name: "", latitude: 52.3676, longitude: 4.9041)
        XCTAssertEqual(location.displayName, Location.coordinateString(latitude: 52.3676, longitude: 4.9041))
    }

    func testDisplayName_WithWhitespaceOnlyName_ReturnsCoordinateString() {
        let location = Location(name: "   ", latitude: 52.3676, longitude: 4.9041)
        XCTAssertEqual(location.displayName, Location.coordinateString(latitude: 52.3676, longitude: 4.9041))
    }

    func testDisplayName_NameWithLeadingTrailingWhitespace_ReturnsName() {
        // Whitespace inside name (not trimmed by displayName itself)
        let location = Location(name: "  Berlin  ", latitude: 52.52, longitude: 13.405)
        XCTAssertEqual(location.displayName, "  Berlin  ")
    }

    // MARK: - coordinateString

    func testCoordinateString_PositiveValues_FormatsToFourDecimalPlaces() {
        let location = Location(name: nil, latitude: 52.3676, longitude: 4.9041)
        XCTAssertEqual(location.coordinateString, "Lat: 52.3676, Lon: 4.9041")
    }

    func testCoordinateString_NegativeValues_FormatsCorrectly() {
        let location = Location(name: nil, latitude: -33.8688, longitude: -70.6693)
        XCTAssertEqual(location.coordinateString, "Lat: -33.8688, Lon: -70.6693")
    }

    func testCoordinateString_ZeroValues_FormatsCorrectly() {
        let location = Location(name: nil, latitude: 0, longitude: 0)
        XCTAssertEqual(location.coordinateString, "Lat: 0.0000, Lon: 0.0000")
    }

    func testCoordinateString_StaticMethod_MatchesInstanceProperty() {
        let lat = 48.8566
        let lon = 2.3522
        let location = Location(name: nil, latitude: lat, longitude: lon)
        XCTAssertEqual(location.coordinateString, Location.coordinateString(latitude: lat, longitude: lon))
    }

    func testCoordinateString_RoundsToFourDecimalPlaces() {
        let location = Location(name: nil, latitude: 1.23456789, longitude: 9.87654321)
        XCTAssertEqual(location.coordinateString, "Lat: 1.2346, Lon: 9.8765")
    }

    // MARK: - Decodable — Location

    func testDecoding_WithAllFields_DecodesCorrectly() throws {
        let json = #"{"name":"Amsterdam","lat":52.3676,"long":4.9041}"#.data(using: .utf8)!
        let location = try JSONDecoder().decode(Location.self, from: json)
        XCTAssertEqual(location.name, "Amsterdam")
        XCTAssertEqual(location.latitude, 52.3676, accuracy: 0.00001)
        XCTAssertEqual(location.longitude, 4.9041, accuracy: 0.00001)
    }

    func testDecoding_WithoutName_SetsNilName() throws {
        let json = #"{"lat":52.3676,"long":4.9041}"#.data(using: .utf8)!
        let location = try JSONDecoder().decode(Location.self, from: json)
        XCTAssertNil(location.name)
    }

    func testDecoding_WithNullName_SetsNilName() throws {
        let json = #"{"name":null,"lat":0,"long":0}"#.data(using: .utf8)!
        let location = try JSONDecoder().decode(Location.self, from: json)
        XCTAssertNil(location.name)
    }

    func testDecoding_MissingLatitude_ThrowsDecodingError() {
        let json = #"{"name":"Amsterdam","long":4.9041}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Location.self, from: json))
    }

    func testDecoding_MissingLongitude_ThrowsDecodingError() {
        let json = #"{"name":"Amsterdam","lat":52.3676}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Location.self, from: json))
    }

    func testDecoding_UsesLatKeyForLatitude() throws {
        // Ensures the "lat" CodingKey is wired correctly (not "latitude")
        let json = #"{"latitude":52.3676,"long":4.9041}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Location.self, from: json))
    }

    func testDecoding_UsesLongKeyForLongitude() throws {
        // Ensures the "long" CodingKey is wired correctly (not "longitude")
        let json = #"{"lat":52.3676,"longitude":4.9041}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Location.self, from: json))
    }

    func testDecoding_NegativeCoordinates_DecodesCorrectly() throws {
        let json = #"{"lat":-33.8688,"long":-70.6693}"#.data(using: .utf8)!
        let location = try JSONDecoder().decode(Location.self, from: json)
        XCTAssertEqual(location.latitude, -33.8688, accuracy: 0.00001)
        XCTAssertEqual(location.longitude, -70.6693, accuracy: 0.00001)
    }

    // MARK: - Decodable — LocationResponse

    func testDecoding_LocationResponse_DecodesMultipleLocations() throws {
        let json = """
        {"locations":[
            {"name":"Amsterdam","lat":52.3676,"long":4.9041},
            {"lat":40.7128,"long":-74.0060}
        ]}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(LocationResponse.self, from: json)
        XCTAssertEqual(response.locations.count, 2)
        XCTAssertEqual(response.locations[0].name, "Amsterdam")
        XCTAssertNil(response.locations[1].name)
    }

    func testDecoding_LocationResponse_EmptyArray_DecodesCorrectly() throws {
        let json = #"{"locations":[]}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(LocationResponse.self, from: json)
        XCTAssertTrue(response.locations.isEmpty)
    }

    // MARK: - Equatable

    func testEquality_SameID_AreEqual() {
        let id = UUID()
        let a = Location(id: id, name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        let b = Location(id: id, name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        XCTAssertEqual(a, b)
    }

    func testEquality_DifferentAutoIDs_AreNotEqual() {
        let a = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        let b = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        XCTAssertNotEqual(a, b)
    }

    func testEquality_SameIDDifferentName_AreNotEqual() {
        let id = UUID()
        let a = Location(id: id, name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        let b = Location(id: id, name: "Rotterdam", latitude: 52.3676, longitude: 4.9041)
        XCTAssertNotEqual(a, b)
    }

    func testEquality_SameIDDifferentLatitude_AreNotEqual() {
        let id = UUID()
        let a = Location(id: id, name: "X", latitude: 10.0, longitude: 5.0)
        let b = Location(id: id, name: "X", latitude: 11.0, longitude: 5.0)
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Identifiable

    func testIdentifiable_IDIsUUID() {
        let location = Location(name: "Test", latitude: 0, longitude: 0)
        XCTAssertNotNil(location.id)
    }

    func testIdentifiable_ExplicitIDIsPreserved() {
        let id = UUID()
        let location = Location(id: id, name: "Test", latitude: 0, longitude: 0)
        XCTAssertEqual(location.id, id)
    }
}
