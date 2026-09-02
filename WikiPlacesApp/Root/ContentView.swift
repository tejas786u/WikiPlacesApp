//
//  ContentView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import SwiftUI

struct ContentView: View {
    let interactor: LocationsListBusinessLogic
    @ObservedObject var presenter: LocationsListPresenter
    let router: LocationsListRoutingLogic
    @State private var isShowingCustomLocationSheet = false

    var body: some View {
        NavigationStack {
            LocationsListView(interactor: interactor, presenter: presenter)
                .navigationTitle("Places")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingCustomLocationSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .accessibilityLabel("Enter a custom location")
                    }
                }
        }
        .sheet(isPresented: $isShowingCustomLocationSheet) {
            router.routeToCustomLocation()
        }
        .alert("Wikipedia App Not Found", isPresented: $presenter.isShowingNotInstalledAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Install the modified Wikipedia app to open locations there.")
        }
    }
}

#Preview {
    let scene = LocationsListSceneBuilder.build(dependencyInjector: DependencyInjector())
    ContentView(interactor: scene.interactor, presenter: scene.presenter, router: scene.router)
}
