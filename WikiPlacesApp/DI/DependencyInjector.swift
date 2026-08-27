//
//  DependencyInjector.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

final class DependencyInjector {
    private let networkService: NetworkServiceProtocol = NetworkService()
    lazy var locationService: LocationRepositoryProtocol = LocationServiceImp(networkService: networkService)
    lazy var wikiOpener: wikipediaOpener = wikipediaOpener(wikipediaDeeplink: WikipediaDeepLink())

    func makeLocationsViewModel() -> LocationsListViewModel {
        LocationsListViewModel(locationService: locationService, wikiOpener: wikiOpener)
    }
}
