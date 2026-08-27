//
//  ListContentView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

struct ListContentView: View {
    @ObservedObject var viewModel: LocationListViewModel
    var body: some View {
        switch viewModel.state {
        case .idle, .loading:
            LazyVStack(spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in
                    LocationCardSkeleton()
                }
            }
            .transition(.opacity)

        case .loaded(let locations) where locations.isEmpty:
            EmptyLocationsView {
                Task { await viewModel.retry() }
            }
            .padding(.top, 64)

        case .loaded(let locations):
            LazyVStack(spacing: 14) {
                ForEach(Array(locations.enumerated()), id: \.element.id) { index, location in
                    LocationCard(location: location) {
                        //Launcher app code will be here
                    }
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity
                        )
                    )
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.82)
                            .delay(Double(index) * 0.05),
                        value: viewModel.state
                    )
                }
            }

        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.retry() }
            }
            .padding(.top, 64)
        }
    }
}

#Preview {
    LocationsListView(viewModel: LocationListViewModel(
        fetchLocations: LocationServiceImp(networkService: NetworkService())
    ))
}
