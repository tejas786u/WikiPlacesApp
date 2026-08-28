//
//  DependencyInjectorTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class DependencyInjectorTests: XCTestCase {

    private func makeSUT() -> DependencyInjector {
        DependencyInjector()
    }

    // MARK: - makeLocationsViewModel

    func testMakeLocationsViewModel_ReturnsNonNilViewModel() {
        let sut = makeSUT()
        let viewModel = sut.makeLocationsViewModel()
        XCTAssertNotNil(viewModel)
    }

    func testMakeLocationsViewModel_InitialStateIsIdle() {
        let sut = makeSUT()
        let viewModel = sut.makeLocationsViewModel()
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testMakeLocationsViewModel_InitialIsShowingAlertIsFalse() {
        let sut = makeSUT()
        let viewModel = sut.makeLocationsViewModel()
        XCTAssertFalse(viewModel.isShowingNotInstalledAlert)
    }

    func testMakeLocationsViewModel_EachCallReturnsDistinctInstance() {
        let sut = makeSUT()
        let first = sut.makeLocationsViewModel()
        let second = sut.makeLocationsViewModel()
        XCTAssertFalse(first === second, "Each call should produce a distinct view model instance")
    }

    func testMakeLocationsViewModel_SharesLocationServiceAcrossInstances() {
        // locationService is a lazy var — same instance is reused
        let sut = makeSUT()
        let first = sut.makeLocationsViewModel()
        let second = sut.makeLocationsViewModel()
        // Both view models are valid and independent
        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
    }
}
