//
//  LocationsWorkerTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 02/09/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class LocationsWorkerTests: XCTestCase {

    private func makeSUT(
        networkResult: MockNetworkService.MockResult = .success(LocationResponse(locations: []))
    ) -> (sut: LocationsWorker, network: MockNetworkService) {
        let network = MockNetworkService()
        network.result = networkResult
        let sut = LocationsWorker(networkService: network)
        return (sut, network)
    }

    // MARK: - fetchLocations

    func testFetchLocations_Success_ReturnsLocations() async throws {
        let locations = [
            Location(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041),
            Location(name: "New York", latitude: 40.7128, longitude: -74.0060)
        ]
        let (sut, _) = makeSUT(networkResult: .success(LocationResponse(locations: locations)))

        let result = try await sut.fetchLocations()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Amsterdam")
        XCTAssertEqual(result[1].name, "New York")
    }

    func testFetchLocations_EmptyList_ReturnsEmptyArray() async throws {
        let (sut, _) = makeSUT(networkResult: .success(LocationResponse(locations: [])))

        let result = try await sut.fetchLocations()

        XCTAssertTrue(result.isEmpty)
    }

    func testFetchLocations_LocationsWithNilName_PreservesNilName() async throws {
        let locations = [Location(name: nil, latitude: 0, longitude: 0)]
        let (sut, _) = makeSUT(networkResult: .success(LocationResponse(locations: locations)))

        let result = try await sut.fetchLocations()

        XCTAssertNil(result[0].name)
    }

    func testFetchLocations_NetworkFailure_ThrowsError() async {
        let (sut, _) = makeSUT(networkResult: .failure(NetworkError.invalidResponse))

        do {
            _ = try await sut.fetchLocations()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func testFetchLocations_NetworkError_ThrowsNetworkError() async {
        let (sut, _) = makeSUT(networkResult: .failure(NetworkError.networkError("timeout")))

        do {
            _ = try await sut.fetchLocations()
            XCTFail("Expected error to be thrown")
        } catch NetworkError.networkError(let message) {
            XCTAssertEqual(message, "timeout")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchLocations_CallsNetworkServiceOnce() async throws {
        let (sut, network) = makeSUT()

        _ = try await sut.fetchLocations()

        XCTAssertEqual(network.fetchCallCount, 1)
    }

    func testFetchLocations_CalledTwice_FetchesTwice() async throws {
        let (sut, network) = makeSUT()

        _ = try await sut.fetchLocations()
        _ = try await sut.fetchLocations()

        XCTAssertEqual(network.fetchCallCount, 2)
    }

    func testFetchLocations_UsesDefaultURL() async throws {
        let (sut, network) = makeSUT()

        _ = try await sut.fetchLocations()

        let expected = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!
        XCTAssertEqual(network.lastFetchedURL, expected)
    }

    func testFetchLocations_CustomURL_FetchesFromCustomURL() async throws {
        let network = MockNetworkService()
        network.result = .success(LocationResponse(locations: []))
        let customURL = URL(string: "https://custom.example.com/locations.json")!
        let sut = LocationsWorker(networkService: network, defaultURL: customURL)

        _ = try await sut.fetchLocations()

        XCTAssertEqual(network.lastFetchedURL, customURL)
    }
}
