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

    private func makeSUT(result: MockLocationsService.Result = .success([])) -> (sut: LocationsListViewModel, service: MockLocationsService) {
        let service = MockLocationsService()
        service.result = result
        let sut = LocationsListViewModel(locationService: service)
        return (sut, service)
    }

    private func makeLocations(count: Int = 1) -> [Location] {
        (0..<count).map { i in
            Location(name: "Place \(i)", latitude: Double(i), longitude: Double(i))
        }
    }

    // MARK: - Initial State

    func testInitialStateIsIdle() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.state, .idle)
    }

    // MARK: - loadIfNeeded

    func testLoadIfNeeded_WhenIdle_TransitionsToLoaded() async {
        let locations = makeLocations(count: 2)
        let (sut, _) = makeSUT(result: .success(locations))

        await sut.loadIfNeeded()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Place 0")
        XCTAssertEqual(result[1].name, "Place 1")
    }

    func testLoadIfNeeded_WhenIdle_TransitionsToErrorOnFailure() async {
        let (sut, _) = makeSUT(result: .failure(NetworkError.invalidResponse))

        await sut.loadIfNeeded()

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func testLoadIfNeeded_WhenAlreadyLoaded_DoesNotFetchAgain() async {
        let (sut, service) = makeSUT(result: .success(makeLocations()))

        await sut.loadIfNeeded() // first call — fetches
        await sut.loadIfNeeded() // second call — should be skipped (state is .loaded)

        XCTAssertEqual(service.fetchCallCount, 1)
    }

    func testLoadIfNeeded_WhenInErrorState_DoesNotFetch() async {
        let (sut, service) = makeSUT(result: .failure(NetworkError.invalidResponse))

        await sut.loadIfNeeded() // transitions to .error
        await sut.loadIfNeeded() // should be skipped

        XCTAssertEqual(service.fetchCallCount, 1)
    }

    func testLoadIfNeeded_WithEmptyLocations_TransitionsToLoadedEmpty() async {
        let (sut, _) = makeSUT(result: .success([]))

        await sut.loadIfNeeded()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - retry

    func testRetry_AlwaysFetches_RegardlessOfState() async {
        let (sut, service) = makeSUT(result: .success(makeLocations()))

        await sut.loadIfNeeded() // state becomes .loaded
        await sut.retry()        // should still fetch

        XCTAssertEqual(service.fetchCallCount, 2)
    }

    func testRetry_FromErrorState_TransitionsToLoaded() async {
        let service = MockLocationsService()
        let sut = LocationsListViewModel(locationService: service)

        service.result = .failure(NetworkError.invalidResponse)
        await sut.loadIfNeeded() // now in .error

        service.result = .success(makeLocations(count: 1))
        await sut.retry()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded after retry, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 1)
    }

    func testRetry_OnFailure_TransitionsToError() async {
        let (sut, _) = makeSUT(result: .failure(NetworkError.decodingError("bad JSON")))

        await sut.retry()

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    // MARK: - refresh

    func testRefresh_AlwaysFetches_RegardlessOfState() async {
        let (sut, service) = makeSUT(result: .success(makeLocations()))

        await sut.loadIfNeeded() // state becomes .loaded
        await sut.refresh()      // should still fetch

        XCTAssertEqual(service.fetchCallCount, 2)
    }

    func testRefresh_UpdatesLoadedLocations() async {
        let service = MockLocationsService()
        let sut = LocationsListViewModel(locationService: service)

        service.result = .success(makeLocations(count: 1))
        await sut.loadIfNeeded()

        service.result = .success(makeLocations(count: 3))
        await sut.refresh()

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded after refresh, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 3)
    }

    // MARK: - fetchCallCount

    func testFetchCallCount_TracksEachCall() async {
        let (sut, service) = makeSUT(result: .success([]))

        await sut.loadIfNeeded()
        await sut.retry()
        await sut.refresh()

        // loadIfNeeded (1) + retry (1) + refresh (1)
        XCTAssertEqual(service.fetchCallCount, 3)
    }
}
