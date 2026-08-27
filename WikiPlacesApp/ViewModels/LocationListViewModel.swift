//
//  LocationListViewModel.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation
import Combine

enum States: Equatable {
    case idle
    case loading
    case loaded([Location])
    case error(String)
}

class LocationListViewModel: ObservableObject {
    @Published private(set) var state: States = .idle
    
    private let fetchLocations: LocationServiceImp
    
    init(fetchLocations: LocationServiceImp = LocationServiceImp(networkService: NetworkService())) {
        self.fetchLocations = fetchLocations
    }
    
    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await loadLocations()
    }

    func retry() async {
        await loadLocations()
    }

    func refresh() async {
        await loadLocations()
    }
    
    func loadLocations() async {
        state = .loading
        do {
            let locations = try await fetchLocations.fetchLocations()
            state = .loaded(locations)
        } catch {
            state = .error(error.localizedDescription)
        }
        
    }
}
