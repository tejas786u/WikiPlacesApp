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
    private lazy var locationService: LocationRepositoryProtocol = {
        if self.useLocalData {
            return LocalLocationService() as LocationRepositoryProtocol
        } else {
            return LocationServiceImp(networkService: networkService) as LocationRepositoryProtocol
        }
    }()
    private lazy var wikiOpener: DeepLinkOpenerProtocol = WikipediaOpener(deepLink: WikipediaDeepLink())

    // MARK: - Factory
    func makeLocationsViewModel() -> LocationsListViewModel {
        LocationsListViewModel(locationService: locationService, wikiOpener: wikiOpener)
    }
}
