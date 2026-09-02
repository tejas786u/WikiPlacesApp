//
//  LocationsListPresenterTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 02/09/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class LocationsListPresenterTests: XCTestCase {

    private func makeSUT() -> LocationsListPresenter {
        LocationsListPresenter()
    }

    private func makeLocations(count: Int = 1) -> [Location] {
        (0..<count).map { i in
            Location(name: "Place \(i)", latitude: Double(i), longitude: Double(i))
        }
    }

    // MARK: - Initial State

    func testInitialStateIsIdle() {
        let sut = makeSUT()
        XCTAssertEqual(sut.state, .idle)
    }

    func testInitialIsShowingNotInstalledAlert_IsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isShowingNotInstalledAlert)
    }

    // MARK: - presentLoading

    func testPresentLoading_SetsStateToLoading() {
        let sut = makeSUT()
        sut.presentLoading()
        XCTAssertEqual(sut.state, .loading)
    }

    // MARK: - presentLoad

    func testPresentLoad_Success_SetsStateToLoaded() {
        let sut = makeSUT()
        let locations = makeLocations(count: 2)

        sut.presentLoad(response: LocationsList.Load.Response(result: .success(locations)))

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertEqual(result.count, 2)
    }

    func testPresentLoad_Failure_SetsStateToError() {
        let sut = makeSUT()

        sut.presentLoad(response: LocationsList.Load.Response(result: .failure(NetworkError.invalidResponse)))

        guard case .error(let message) = sut.state else {
            return XCTFail("Expected .error, got \(sut.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func testPresentLoad_EmptySuccess_SetsStateToLoadedEmpty() {
        let sut = makeSUT()

        sut.presentLoad(response: LocationsList.Load.Response(result: .success([])))

        guard case .loaded(let result) = sut.state else {
            return XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - presentOpenResult

    func testPresentOpenResult_Success_DoesNotShowAlert() {
        let sut = makeSUT()

        sut.presentOpenResult(response: LocationsList.OpenLocation.Response(success: true))

        XCTAssertFalse(sut.isShowingNotInstalledAlert)
    }

    func testPresentOpenResult_Failure_ShowsAlert() {
        let sut = makeSUT()

        sut.presentOpenResult(response: LocationsList.OpenLocation.Response(success: false))

        XCTAssertTrue(sut.isShowingNotInstalledAlert)
    }

    func testPresentOpenResult_SuccessAfterPreviousFailure_AlertRemainsTrue() {
        let sut = makeSUT()

        sut.presentOpenResult(response: LocationsList.OpenLocation.Response(success: false))
        sut.presentOpenResult(response: LocationsList.OpenLocation.Response(success: true))

        XCTAssertTrue(sut.isShowingNotInstalledAlert)
    }
}
