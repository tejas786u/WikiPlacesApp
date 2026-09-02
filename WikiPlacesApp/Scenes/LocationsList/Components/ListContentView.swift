//
//  ListContentView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import SwiftUI

struct ListContentView: View {
    let interactor: LocationsListBusinessLogic
    @ObservedObject var presenter: LocationsListPresenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        switch presenter.state {
        case .idle, .loading:
            LazyVStack(spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in
                    LocationCardSkeleton()
                }
            }
            .transition(.opacity)

        case .loaded(let locations) where locations.isEmpty:
            EmptyLocationsView {
                Task { await interactor.retry() }
            }
            .padding(.top, 64)

        case .loaded(let locations):
            LazyVStack(spacing: 14) {
                ForEach(Array(locations.enumerated()), id: \.element.id) { index, location in
                    LocationCard(location: location, index: index) {
                        Task {
                            await interactor.open(location: location)
                        }
                    }
                }
            }

        case .error(let message):
            ErrorStateView(message: message) {
                Task { await interactor.retry() }
            }
            .padding(.top, 64)
        }
    }
}

#Preview {
    let scene = LocationsListSceneBuilder.build(dependencyInjector: DependencyInjector())
    LocationsListView(interactor: scene.interactor, presenter: scene.presenter)
}
