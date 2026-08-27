//
//  ContentView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locationListViewModel: LocationsListViewModel
    @State private var isShowingCustomLocationSheet = false
    
    var body: some View {
        NavigationStack {
            LocationsListView(viewModel: locationListViewModel)
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
            //Custome Location popup implementation will be here.
        }
        .alert("Wikipedia App Not Found", isPresented: $locationListViewModel.isShowingNotInstalledAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Install the modified Wikipedia app to open locations there.")
        }
    }
}

#Preview {
    ContentView(locationListViewModel: DependencyInjector().makeLocationsViewModel())
}
