//
//  LocationsListSceneBuilder.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

@MainActor
enum LocationsListSceneBuilder {
    static func build(dependencyInjector: DependencyInjector) -> (
        interactor: LocationsListBusinessLogic,
        presenter: LocationsListPresenter,
        router: LocationsListRouter
    ) {
        let presenter = LocationsListPresenter()
        let interactor = LocationsListInteractor(
            worker: dependencyInjector.makeLocationsWorker(),
            deepLinkWorker: dependencyInjector.makeDeepLinkWorker()
        )
        interactor.presenter = presenter

        let router = LocationsListRouter(dependencyInjector: dependencyInjector)
        router.dataStore = interactor

        return (interactor, presenter, router)
    }
}
