//
//  LocationsListView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

struct LocationsListView: View {
    @ObservedObject var viewModel: LocationsListViewModel
    var body: some View {
        ScrollView {
            ListContentView(viewModel: viewModel)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .background(BackgroundGradient())
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}

#Preview {
    LocationsListView(viewModel: LocationsListViewModel(
        locationService: LocationServiceImp(networkService: NetworkService()),
        wikiOpener: wikipediaOpener(wikipediaDeeplink: WikipediaDeepLink())
    ))
}
