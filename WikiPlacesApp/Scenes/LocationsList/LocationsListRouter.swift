//
//  LocationsListRouter.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

// MARK: - Routing Logic Protocol
protocol LocationsListRoutingLogic {
    @MainActor
    func routeToCustomLocation() -> CustomLocationView
}

// MARK: - Data Passing
protocol LocationsListDataPassing {
    var dataStore: LocationsListDataStore? { get }
}

final class LocationsListRouter: LocationsListRoutingLogic, LocationsListDataPassing {
    var dataStore: LocationsListDataStore?
    private let dependencyInjector: DependencyInjector

    init(dependencyInjector: DependencyInjector) {
        self.dependencyInjector = dependencyInjector
    }

    @MainActor
    func routeToCustomLocation() -> CustomLocationView {
        CustomLocationSceneBuilder.build(dependencyInjector: dependencyInjector)
    }
}
