//
//  LocationsListView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

struct LocationsListView: View {
    @ObservedObject var viewModel: LocationListViewModel
    var body: some View {
        ScrollView {
            ListContentView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .background(BackgroundGradient())
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

#Preview {
    LocationsListView(viewModel: LocationListViewModel(
        fetchLocations: LocationServiceImp(networkService: NetworkService())
    ))
}
