//
//  Mocks.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 27/08/26.
//

import XCTest
import Foundation
@testable import WikiPlacesApp

// MARK: - MockLocationsWorker

final class MockLocationsWorker: LocationsWorkerProtocol {
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

// MARK: - MockDeepLinkWorker

@MainActor
final class MockDeepLinkWorker: DeepLinkWorkerProtocol {
    var shouldSucceed = true
    private(set) var openCallCount = 0
    private(set) var lastOpenedLocation: Location?

    func openDeepLink(for location: Location) async -> Bool {
        openCallCount += 1
        lastOpenedLocation = location
        return shouldSucceed
    }
}

// MARK: - MockLocationsListPresenter (spy)

@MainActor
final class MockLocationsListPresenter: LocationsListPresentationLogic {
    private(set) var presentLoadingCallCount = 0
    private(set) var loadResponses: [LocationsList.Load.Response] = []
    private(set) var openResponses: [LocationsList.OpenLocation.Response] = []

    func presentLoading() {
        presentLoadingCallCount += 1
    }

    func presentLoad(response: LocationsList.Load.Response) {
        loadResponses.append(response)
    }

    func presentOpenResult(response: LocationsList.OpenLocation.Response) {
        openResponses.append(response)
    }
}

// MARK: - MockCustomLocationPresenter (spy)

@MainActor
final class MockCustomLocationPresenter: CustomLocationPresentationLogic {
    private(set) var validationResponses: [CustomLocation.Validate.Response] = []
    private(set) var openResponses: [CustomLocation.Open.Response] = []

    func presentValidation(response: CustomLocation.Validate.Response) {
        validationResponses.append(response)
    }

    func presentOpenResult(response: CustomLocation.Open.Response) {
        openResponses.append(response)
    }
}

// MARK: - MockNetworkService

final class MockNetworkService: NetworkServiceProtocol {
    enum MockResult {
        case success(Any)
        case failure(Error)
    }

    var result: MockResult = .success(LocationResponse(locations: []))
    private(set) var fetchCallCount = 0
    private(set) var lastFetchedURL: URL?

    func fetch<T: Decodable>(from url: URL) async throws -> T {
        fetchCallCount += 1
        lastFetchedURL = url
        switch result {
        case .success(let value):
            guard let typed = value as? T else {
                throw NetworkError.decodingError("MockNetworkService: type mismatch — expected \(T.self)")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
