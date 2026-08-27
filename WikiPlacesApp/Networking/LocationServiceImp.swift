//
//  LocationService.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

protocol LocationRepositoryProtocol {
    func fetchLocations() async throws -> [Location]
}

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
