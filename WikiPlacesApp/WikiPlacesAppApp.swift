//
//  WikiPlacesAppApp.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

@MainActor
@main
struct WikiPlacesAppApp: App {
    private let dependencyInjector = DependencyInjector()
    @StateObject private var presenter: LocationsListPresenter
    private let interactor: LocationsListBusinessLogic
    private let router: LocationsListRoutingLogic

    init() {
        let scene = LocationsListSceneBuilder.build(dependencyInjector: dependencyInjector)
        _presenter = StateObject(wrappedValue: scene.presenter)
        interactor = scene.interactor
        router = scene.router
    }

    var body: some Scene {
        WindowGroup {
            ContentView(interactor: interactor, presenter: presenter, router: router)
        }
    }
}
