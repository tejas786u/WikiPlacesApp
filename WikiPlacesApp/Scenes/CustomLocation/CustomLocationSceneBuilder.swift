//
//  CustomLocationSceneBuilder.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

@MainActor
enum CustomLocationSceneBuilder {
    static func build(dependencyInjector: DependencyInjector) -> CustomLocationView {
        let presenter = CustomLocationPresenter()
        let interactor = CustomLocationInteractor(deepLinkWorker: dependencyInjector.makeDeepLinkWorker())
        interactor.presenter = presenter
        return CustomLocationView(interactor: interactor, presenter: presenter)
    }
}
