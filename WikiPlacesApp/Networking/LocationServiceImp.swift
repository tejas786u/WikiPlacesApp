//
//  LocationService.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

// MARK: - Protocol
protocol LocationRepositoryProtocol {
    func fetchLocations() async throws -> [Location]
}

// MARK: - Remote Service
struct LocationServiceImp: LocationRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let defaultURL: URL

    init(networkService: NetworkServiceProtocol, defaultURL: URL = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!) {
        self.networkService = networkService
        self.defaultURL = defaultURL
    }

    func fetchLocations() async throws -> [Location] {
        let response: LocationResponse = try await networkService.fetch(from: defaultURL)
        return response.locations
    }
}

// MARK: - Local Service (offline / for API response validation)
struct LocalLocationService: LocationRepositoryProtocol {
    func fetchLocations() async throws -> [Location] {
        guard let url = Bundle.main.url(forResource: "locations", withExtension: "json") else {
            throw NetworkError.invalidURL
        }
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(LocationResponse.self, from: data)
        return response.locations
    }
}
