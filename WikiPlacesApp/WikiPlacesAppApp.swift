//
//  WikiPlacesAppApp.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

@main
struct WikiPlacesAppApp: App {
    @StateObject private var locationListViewModel: LocationsListViewModel

    init() {
        _locationListViewModel = StateObject(wrappedValue: DependencyInjector().makeLocationsViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(locationListViewModel: locationListViewModel)
        }
    }
}
