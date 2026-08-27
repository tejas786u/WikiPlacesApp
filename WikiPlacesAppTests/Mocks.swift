//
//  Mocks.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 27/08/26.
//

import XCTest
@testable import WikiPlacesApp

final class MockLocationsService: LocationRepositoryProtocol {
    enum Result {
        case success([Location])
        case failure(Error)
    }

    var result: Result = .success([])
    private(set) var fetchCallCount = 0

    func fetchLocations() async throws -> [Location] {
        fetchCallCount += 1
        switch result {
        case .success(let locations):
            return locations
        case .failure(let error):
            throw error
        }
    }
}
