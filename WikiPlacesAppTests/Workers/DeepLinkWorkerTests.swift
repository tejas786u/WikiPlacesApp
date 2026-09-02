//
//  DeepLinkWorkerTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 02/09/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class DeepLinkWorkerTests: XCTestCase {

    private var mockBuilder: MockDeepLinkCreator!
    private var worker: DeepLinkWorker!

    override func setUp() {
        super.setUp()
        mockBuilder = MockDeepLinkCreator()
        worker = DeepLinkWorker(deepLink: mockBuilder)
    }

    override func tearDown() {
        mockBuilder = nil
        worker = nil
        super.tearDown()
    }

    // MARK: - Builder returns nil URL

    func testOpenDeepLink_WhenBuilderReturnsNil_ReturnsFalse() async {
        mockBuilder.urlToReturn = nil
        let result = await worker.openDeepLink(for: sampleLocation())
        XCTAssertFalse(result)
    }

    func testOpenDeepLink_WhenBuilderReturnsNil_BuilderIsStillCalledOnce() async {
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: sampleLocation())
        XCTAssertEqual(mockBuilder.createCallCount, 1)
    }

    func testOpenDeepLink_WhenBuilderReturnsNilRepeatedly_ReturnsFalseEachTime() async {
        mockBuilder.urlToReturn = nil
        let r1 = await worker.openDeepLink(for: sampleLocation())
        let r2 = await worker.openDeepLink(for: sampleLocation())
        XCTAssertFalse(r1)
        XCTAssertFalse(r2)
    }

    // MARK: - URL scheme not in LSApplicationQueriesSchemes

    func testOpenDeepLink_WhenSchemeNotRegistered_ReturnsFalse() async {
        // canOpenURL returns false for schemes not listed in LSApplicationQueriesSchemes
        mockBuilder.urlToReturn = URL(string: "x-wiki-unregistered://places?lat=1&lon=1")
        let result = await worker.openDeepLink(for: sampleLocation())
        XCTAssertFalse(result)
    }

    func testOpenDeepLink_WhenSchemeNotRegistered_BuilderIsCalledOnce() async {
        mockBuilder.urlToReturn = URL(string: "x-wiki-unregistered://places?lat=1&lon=1")
        _ = await worker.openDeepLink(for: sampleLocation())
        XCTAssertEqual(mockBuilder.createCallCount, 1)
    }

    // MARK: - Builder receives correct location

    func testOpenDeepLink_PassesCorrectLatitudeToBuilder() async throws {
        let loc = Location(name: nil, latitude: 52.3676, longitude: 4.9041)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc)
        let received = try XCTUnwrap(mockBuilder.lastLocation)
        XCTAssertEqual(received.latitude, 52.3676, accuracy: 1e-5)
    }

    func testOpenDeepLink_PassesCorrectLongitudeToBuilder() async throws {
        let loc = Location(name: nil, latitude: 52.3676, longitude: 4.9041)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc)
        let received = try XCTUnwrap(mockBuilder.lastLocation)
        XCTAssertEqual(received.longitude, 4.9041, accuracy: 1e-5)
    }

    func testOpenDeepLink_PassesCorrectNameToBuilder() async throws {
        let loc = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc)
        let received = try XCTUnwrap(mockBuilder.lastLocation)
        XCTAssertEqual(received.name, "Amsterdam")
    }

    func testOpenDeepLink_PassesNilNameToBuilder() async throws {
        let loc = Location(name: nil, latitude: 0, longitude: 0)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc)
        let received = try XCTUnwrap(mockBuilder.lastLocation)
        XCTAssertNil(received.name)
    }

    func testOpenDeepLink_PassesNegativeCoordinatesToBuilder() async throws {
        let loc = Location(name: nil, latitude: -33.8688, longitude: -70.6693)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc)
        let received = try XCTUnwrap(mockBuilder.lastLocation)
        XCTAssertEqual(received.latitude, -33.8688, accuracy: 1e-5)
        XCTAssertEqual(received.longitude, -70.6693, accuracy: 1e-5)
    }

    func testOpenDeepLink_PassesBoundaryCoordinatesToBuilder() async throws {
        let loc = Location(name: nil, latitude: 90, longitude: 180)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc)
        let received = try XCTUnwrap(mockBuilder.lastLocation)
        XCTAssertEqual(received.latitude, 90, accuracy: 1e-5)
        XCTAssertEqual(received.longitude, 180, accuracy: 1e-5)
    }

    // MARK: - Multiple calls

    func testOpenDeepLink_CalledTwice_BuilderCalledTwice() async {
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: sampleLocation())
        _ = await worker.openDeepLink(for: sampleLocation())
        XCTAssertEqual(mockBuilder.createCallCount, 2)
    }

    func testOpenDeepLink_CalledThreeTimes_BuilderCalledThreeTimes() async {
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: sampleLocation())
        _ = await worker.openDeepLink(for: sampleLocation())
        _ = await worker.openDeepLink(for: sampleLocation())
        XCTAssertEqual(mockBuilder.createCallCount, 3)
    }

    func testOpenDeepLink_LastLocationIsUpdatedOnEachCall() async {
        let loc1 = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
        let loc2 = Location(name: "Sydney", latitude: -33.8688, longitude: 151.2093)
        mockBuilder.urlToReturn = nil
        _ = await worker.openDeepLink(for: loc1)
        _ = await worker.openDeepLink(for: loc2)
        XCTAssertEqual(mockBuilder.lastLocation?.name, "Sydney")
    }

    // MARK: - Helpers

    private func sampleLocation() -> Location {
        Location(name: nil, latitude: 52.3676, longitude: 4.9041)
    }
}

// MARK: - Mock

private final class MockDeepLinkCreator: DeepLinkCreateProtocol {
    var urlToReturn: URL?
    private(set) var createCallCount = 0
    private(set) var lastLocation: Location?

    func createDeepLink(for location: Location) -> URL? {
        createCallCount += 1
        lastLocation = location
        return urlToReturn
    }
}
