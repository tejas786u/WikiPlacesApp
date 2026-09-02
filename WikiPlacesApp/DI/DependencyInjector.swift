//
//  DependencyInjector.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

final class DependencyInjector {

    // MARK: - Configuration
    private let useLocalData = false  // Make it 'true' to load data from bundled JSON file.

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol = NetworkService()
    private lazy var locationsWorker: LocationsWorkerProtocol = {
        if self.useLocalData {
            return LocalLocationsWorker() as LocationsWorkerProtocol
        } else {
            return LocationsWorker(networkService: networkService) as LocationsWorkerProtocol
        }
    }()
    private lazy var deepLinkWorker: DeepLinkWorkerProtocol = DeepLinkWorker(deepLink: WikipediaDeepLink())

    // MARK: - Factory
    func makeLocationsWorker() -> LocationsWorkerProtocol {
        locationsWorker
    }

    func makeDeepLinkWorker() -> DeepLinkWorkerProtocol {
        deepLinkWorker
    }
}
