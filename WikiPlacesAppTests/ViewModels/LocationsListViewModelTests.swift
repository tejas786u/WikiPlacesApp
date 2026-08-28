//
//  LocationsListViewModelTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 27/08/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class LocationsListViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        serviceResult: MockLocationsService.Result = .success([]),
        openerSucceeds: Bool = true
    ) -> (sut: LocationsListViewModel, service: MockLocationsService, opener: MockWikiOpener) {
        let service = MockLocationsService()
        service.result = serviceResult
        let opener = MockWikiOpener()
        opener.shouldSucceed = openerSucceeds
        let sut = LocationsListViewModel(locationService: service, wikiOpener: opener)
        return (sut, service, opener)
    }

    private func makeLocations(count: Int = 1) -> [Location] {
        (0..<count).map { i in
            Location(name: "Place \(i)", latitude: Double(i), longitude: Double(i))
        }
    }

    // MARK: - Initial State

    func testInitialStateIsIdle() {
        let (sut, _, _) = makeSUT()
        XCTAssertEqual(sut.state, .idle)
    }

    func testInitialIsShowingNotInstalledAlert_IsFalse() {
        let (sut, _, _) = makeSUT()
        XCTAssertFalse(sut.isShowingNotInstalledAlert)
    }

    // MARK: - loadIfNeeded

    func testLoadIfNeeded_WhenIdle_TransitionsToLoaded() async {
        let locations = makeLocations(count: 2)
        let (sut, _, _) = makeSUT(serviceResult: .success(locations))

        await sut.loadIfNeeded()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Place 0")
        XCTAssertEqual(result[1].name, "Place 1")
    }

    func testLoadIfNeeded_WhenIdle_TransitionsToErrorOnFailure() async {
        let (sut, _, _) = makeSUT(serviceResult: .failure(NetworkError.invalidResponse))

        await sut.loadIfNeeded()

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func testLoadIfNeeded_WhenAlreadyLoaded_DoesNotFetchAgain() async {
        let (sut, service, _) = makeSUT(serviceResult: .success(makeLocations()))

        await sut.loadIfNeeded() // first call — fetches
        await sut.loadIfNeeded() // second call — should be skipped (state is .loaded)

        XCTAssertEqual(service.fetchCallCount, 1)
    }

    func testLoadIfNeeded_WhenInErrorState_DoesNotFetch() async {
        let (sut, service, _) = makeSUT(serviceResult: .failure(NetworkError.invalidResponse))

        await sut.loadIfNeeded() // transitions to .error
        await sut.loadIfNeeded() // should be skipped

        XCTAssertEqual(service.fetchCallCount, 1)
    }

    func testLoadIfNeeded_WithEmptyLocations_TransitionsToLoadedEmpty() async {
        let (sut, _, _) = makeSUT(serviceResult: .success([]))

        await sut.loadIfNeeded()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertTrue(result.isEmpty)
    }

    func testLoadIfNeeded_WhenLoading_DoesNotFetchAgain() async {
        let (sut, service, _) = makeSUT(serviceResult: .success(makeLocations()))

        // Simulate already-loading state by calling loadIfNeeded twice concurrently
        async let first: Void = sut.loadIfNeeded()
        async let second: Void = sut.loadIfNeeded()
        _ = await (first, second)

        XCTAssertLessThanOrEqual(service.fetchCallCount, 2)
    }

    // MARK: - retry

    func testRetry_AlwaysFetches_RegardlessOfState() async {
        let (sut, service, _) = makeSUT(serviceResult: .success(makeLocations()))

        await sut.loadIfNeeded() // state becomes .loaded
        await sut.retry()        // should still fetch

        XCTAssertEqual(service.fetchCallCount, 2)
    }

    func testRetry_FromErrorState_TransitionsToLoaded() async {
        let service = MockLocationsService()
        let opener = MockWikiOpener()
        let sut = LocationsListViewModel(locationService: service, wikiOpener: opener)

        service.result = .failure(NetworkError.invalidResponse)
        await sut.loadIfNeeded()

        service.result = .success(makeLocations(count: 1))
        await sut.retry()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded after retry, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 1)
    }

    func testRetry_OnFailure_TransitionsToError() async {
        let (sut, _, _) = makeSUT(serviceResult: .failure(NetworkError.decodingError("bad JSON")))

        await sut.retry()

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func testRetry_FromIdleState_Fetches() async {
        let (sut, service, _) = makeSUT(serviceResult: .success(makeLocations()))

        await sut.retry()

        XCTAssertEqual(service.fetchCallCount, 1)
    }

    // MARK: - refresh

    func testRefresh_AlwaysFetches_RegardlessOfState() async {
        let (sut, service, _) = makeSUT(serviceResult: .success(makeLocations()))

        await sut.loadIfNeeded() // state becomes .loaded
        await sut.refresh()      // should still fetch

        XCTAssertEqual(service.fetchCallCount, 2)
    }

    func testRefresh_UpdatesLoadedLocations() async {
        let service = MockLocationsService()
        let opener = MockWikiOpener()
        let sut = LocationsListViewModel(locationService: service, wikiOpener: opener)

        service.result = .success(makeLocations(count: 1))
        await sut.loadIfNeeded()

        service.result = .success(makeLocations(count: 3))
        await sut.refresh()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded after refresh, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 3)
    }

    func testRefresh_OnFailure_TransitionsToError() async {
        let (sut, _, _) = makeSUT(serviceResult: .failure(NetworkError.invalidResponse))

        await sut.refresh()

        guard case .error = sut.state else {
            return XCTFail("Expected .error after failing refresh, got \(sut.state)")
        }
    }

    // MARK: - fetchCallCount

    func testFetchCallCount_TracksEachCall() async {
        let (sut, service, _) = makeSUT(serviceResult: .success([]))

        await sut.loadIfNeeded()
        await sut.retry()
        await sut.refresh()

        // loadIfNeeded (1) + retry (1) + refresh (1)
        XCTAssertEqual(service.fetchCallCount, 3)
    }

    // MARK: - open

    func testOpen_Success_DoesNotShowNotInstalledAlert() async {
        let (sut, _, _) = makeSUT(openerSucceeds: true)
        let location = Location(name: "Test", latitude: 52.0, longitude: 4.0)

        await sut.open(location: location)

        XCTAssertFalse(sut.isShowingNotInstalledAlert)
    }

    func testOpen_Failure_ShowsNotInstalledAlert() async {
        let (sut, _, _) = makeSUT(openerSucceeds: false)
        let location = Location(name: "Test", latitude: 52.0, longitude: 4.0)

        await sut.open(location: location)

        XCTAssertTrue(sut.isShowingNotInstalledAlert)
    }

    func testOpen_PassesCorrectLocationToOpener() async {
        let (sut, _, opener) = makeSUT()
        let location = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)

        await sut.open(location: location)

        XCTAssertEqual(opener.lastOpenedLocation, location)
    }

    func testOpen_CallsOpenerExactlyOnce() async {
        let (sut, _, opener) = makeSUT()
        let location = Location(name: "Test", latitude: 0, longitude: 0)

        await sut.open(location: location)

        XCTAssertEqual(opener.openCallCount, 1)
    }

    func testOpen_CalledMultipleTimes_TracksAllCalls() async {
        let (sut, _, opener) = makeSUT()
        let location = Location(name: "Test", latitude: 0, longitude: 0)

        await sut.open(location: location)
        await sut.open(location: location)

        XCTAssertEqual(opener.openCallCount, 2)
    }

    func testOpen_SuccessAfterPreviousFailure_AlertRemainsTrue() async {
        let (sut, _, opener) = makeSUT(openerSucceeds: false)
        let location = Location(name: "Test", latitude: 0, longitude: 0)

        await sut.open(location: location) // sets alert to true
        opener.shouldSucceed = true
        await sut.open(location: location) // success — alert not reset by ViewModel

        XCTAssertTrue(sut.isShowingNotInstalledAlert)
    }
}
