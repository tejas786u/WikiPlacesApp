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

@MainActor
class LocationsListViewModel: ObservableObject {
    @Published private(set) var state: States = .idle
    @Published var isShowingNotInstalledAlert = false

    private let locationService: LocationRepositoryProtocol
    private let wikiOpener: DeepLinkOpenerProtocol

    init(locationService: LocationRepositoryProtocol, wikiOpener: DeepLinkOpenerProtocol) {
        self.locationService = locationService
        self.wikiOpener = wikiOpener
    }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        state = .loading
        await performFetch()
    }

    func retry() async {
        state = .loading
        await performFetch()
    }

    func refresh() async {
        state = .loading
        await performFetch()
    }
    
    func open(location: Location) async {
        let success = await wikiOpener.openDeepLink(for: location)
        if !success {
            isShowingNotInstalledAlert = true
        }
    }

    private func performFetch() async {
        do {
            let locations = try await locationService.fetchLocations()
            state = .loaded(locations)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
