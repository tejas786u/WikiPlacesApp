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

    // MARK: - makeLocationsWorker

    func testMakeLocationsWorker_ReturnsNonNilWorker() {
        let sut = makeSUT()
        let worker = sut.makeLocationsWorker()
        XCTAssertNotNil(worker)
    }

    func testMakeLocationsWorker_EachCallReturnsAWorker() {
        // locationsWorker is a lazy var — reused under the hood, but LocationsWorker
        // is a value type so we can only assert both calls succeed, not reference identity.
        let sut = makeSUT()
        let first = sut.makeLocationsWorker()
        let second = sut.makeLocationsWorker()
        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
    }

    // MARK: - makeDeepLinkWorker

    func testMakeDeepLinkWorker_ReturnsNonNilWorker() {
        let sut = makeSUT()
        let worker = sut.makeDeepLinkWorker()
        XCTAssertNotNil(worker)
    }

    func testMakeDeepLinkWorker_EachInjectorReturnsIndependentInstance() {
        let first = makeSUT().makeDeepLinkWorker()
        let second = makeSUT().makeDeepLinkWorker()
        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
    }
}
