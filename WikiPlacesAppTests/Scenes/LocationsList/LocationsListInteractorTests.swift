//
//  LocationsListInteractorTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 02/09/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class LocationsListInteractorTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        workerResult: MockLocationsWorker.Result = .success([]),
        openerSucceeds: Bool = true
    ) -> (sut: LocationsListInteractor, worker: MockLocationsWorker, deepLinkWorker: MockDeepLinkWorker, presenter: MockLocationsListPresenter) {
        let worker = MockLocationsWorker()
        worker.result = workerResult
        let deepLinkWorker = MockDeepLinkWorker()
        deepLinkWorker.shouldSucceed = openerSucceeds
        let presenter = MockLocationsListPresenter()
        let sut = LocationsListInteractor(worker: worker, deepLinkWorker: deepLinkWorker)
        sut.presenter = presenter
        return (sut, worker, deepLinkWorker, presenter)
    }

    private func makeLocations(count: Int = 1) -> [Location] {
        (0..<count).map { i in
            Location(name: "Place \(i)", latitude: Double(i), longitude: Double(i))
        }
    }

    // MARK: - Initial State

    func testInitialState_LocationsIsEmpty() {
        let (sut, _, _, _) = makeSUT()
        XCTAssertTrue(sut.locations.isEmpty)
    }

    // MARK: - loadIfNeeded

    func testLoadIfNeeded_WhenIdle_PresentsLoadedLocations() async {
        let locations = makeLocations(count: 2)
        let (sut, _, _, presenter) = makeSUT(workerResult: .success(locations))

        await sut.loadIfNeeded()

        guard case .success(let result) = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a success response")
        }
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(sut.locations.count, 2)
    }

    func testLoadIfNeeded_WhenIdle_PresentsLoadingFirst() async {
        let (sut, _, _, presenter) = makeSUT(workerResult: .success([]))

        await sut.loadIfNeeded()

        XCTAssertEqual(presenter.presentLoadingCallCount, 1)
    }

    func testLoadIfNeeded_WhenIdle_PresentsErrorOnFailure() async {
        let (sut, _, _, presenter) = makeSUT(workerResult: .failure(NetworkError.invalidResponse))

        await sut.loadIfNeeded()

        guard case .failure = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a failure response")
        }
    }

    func testLoadIfNeeded_WhenAlreadyLoaded_DoesNotFetchAgain() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .success(makeLocations()))

        await sut.loadIfNeeded() // first call — fetches
        await sut.loadIfNeeded() // second call — should be skipped (phase is .loaded)

        XCTAssertEqual(worker.fetchCallCount, 1)
    }

    func testLoadIfNeeded_WhenInErrorState_DoesNotFetch() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .failure(NetworkError.invalidResponse))

        await sut.loadIfNeeded() // transitions to .error
        await sut.loadIfNeeded() // should be skipped

        XCTAssertEqual(worker.fetchCallCount, 1)
    }

    func testLoadIfNeeded_WithEmptyLocations_PresentsLoadedEmpty() async {
        let (sut, _, _, presenter) = makeSUT(workerResult: .success([]))

        await sut.loadIfNeeded()

        guard case .success(let result) = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a success response")
        }
        XCTAssertTrue(result.isEmpty)
    }

    func testLoadIfNeeded_WhenLoading_DoesNotFetchAgain() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .success(makeLocations()))

        // Simulate already-loading state by calling loadIfNeeded twice concurrently
        async let first: Void = sut.loadIfNeeded()
        async let second: Void = sut.loadIfNeeded()
        _ = await (first, second)

        XCTAssertLessThanOrEqual(worker.fetchCallCount, 2)
    }

    // MARK: - retry

    func testRetry_AlwaysFetches_RegardlessOfState() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .success(makeLocations()))

        await sut.loadIfNeeded() // phase becomes .loaded
        await sut.retry()        // should still fetch

        XCTAssertEqual(worker.fetchCallCount, 2)
    }

    func testRetry_FromErrorState_PresentsLoaded() async {
        let worker = MockLocationsWorker()
        let deepLinkWorker = MockDeepLinkWorker()
        let presenter = MockLocationsListPresenter()
        let sut = LocationsListInteractor(worker: worker, deepLinkWorker: deepLinkWorker)
        sut.presenter = presenter

        worker.result = .failure(NetworkError.invalidResponse)
        await sut.loadIfNeeded()

        worker.result = .success(makeLocations(count: 1))
        await sut.retry()

        guard case .success(let result) = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a success response after retry")
        }
        XCTAssertEqual(result.count, 1)
    }

    func testRetry_OnFailure_PresentsError() async {
        let (sut, _, _, presenter) = makeSUT(workerResult: .failure(NetworkError.decodingError("bad JSON")))

        await sut.retry()

        guard case .failure = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a failure response")
        }
    }

    func testRetry_FromIdleState_Fetches() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .success(makeLocations()))

        await sut.retry()

        XCTAssertEqual(worker.fetchCallCount, 1)
    }

    // MARK: - refresh

    func testRefresh_AlwaysFetches_RegardlessOfState() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .success(makeLocations()))

        await sut.loadIfNeeded() // phase becomes .loaded
        await sut.retry()      // should still fetch

        XCTAssertEqual(worker.fetchCallCount, 2)
    }

    func testRefresh_UpdatesLoadedLocations() async {
        let worker = MockLocationsWorker()
        let deepLinkWorker = MockDeepLinkWorker()
        let presenter = MockLocationsListPresenter()
        let sut = LocationsListInteractor(worker: worker, deepLinkWorker: deepLinkWorker)
        sut.presenter = presenter

        worker.result = .success(makeLocations(count: 1))
        await sut.loadIfNeeded()

        worker.result = .success(makeLocations(count: 3))
        await sut.retry()

        guard case .success(let result) = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a success response after refresh")
        }
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(sut.locations.count, 3)
    }

    func testRefresh_OnFailure_PresentsError() async {
        let (sut, _, _, presenter) = makeSUT(workerResult: .failure(NetworkError.invalidResponse))

        await sut.retry()

        guard case .failure = presenter.loadResponses.last?.result else {
            return XCTFail("Expected a failure response after failing refresh")
        }
    }

    // MARK: - fetchCallCount

    func testFetchCallCount_TracksEachCall() async {
        let (sut, worker, _, _) = makeSUT(workerResult: .success([]))

        await sut.loadIfNeeded()
        await sut.retry()
        await sut.retry()

        // loadIfNeeded (1) + retry (1) + refresh (1)
        XCTAssertEqual(worker.fetchCallCount, 3)
    }

    // MARK: - open

    func testOpen_Success_DoesNotReportFailure() async {
        let (sut, _, _, presenter) = makeSUT(openerSucceeds: true)
        let location = Location(name: "Test", latitude: 52.0, longitude: 4.0)

        await sut.open(location: location)

        XCTAssertEqual(presenter.openResponses.last?.success, true)
    }

    func testOpen_Failure_ReportsFailure() async {
        let (sut, _, _, presenter) = makeSUT(openerSucceeds: false)
        let location = Location(name: "Test", latitude: 52.0, longitude: 4.0)

        await sut.open(location: location)

        XCTAssertEqual(presenter.openResponses.last?.success, false)
    }

    func testOpen_PassesCorrectLocationToWorker() async {
        let (sut, _, deepLinkWorker, _) = makeSUT()
        let location = Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)

        await sut.open(location: location)

        XCTAssertEqual(deepLinkWorker.lastOpenedLocation, location)
    }

    func testOpen_CallsWorkerExactlyOnce() async {
        let (sut, _, deepLinkWorker, _) = makeSUT()
        let location = Location(name: "Test", latitude: 0, longitude: 0)

        await sut.open(location: location)

        XCTAssertEqual(deepLinkWorker.openCallCount, 1)
    }

    func testOpen_CalledMultipleTimes_TracksAllCalls() async {
        let (sut, _, deepLinkWorker, _) = makeSUT()
        let location = Location(name: "Test", latitude: 0, longitude: 0)

        await sut.open(location: location)
        await sut.open(location: location)

        XCTAssertEqual(deepLinkWorker.openCallCount, 2)
    }
}
