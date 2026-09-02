//
//  LocationsListPresenter.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation
import Combine

// MARK: - Presentation Logic Protocol
protocol LocationsListPresentationLogic {
    func presentLoading()
    func presentLoad(response: LocationsList.Load.Response)
    func presentOpenResult(response: LocationsList.OpenLocation.Response)
}

@MainActor
final class LocationsListPresenter: LocationsListPresentationLogic, ObservableObject {

// MARK: - Published ViewModel State
    @Published private(set) var state: LocationsListState = .idle
    @Published var isShowingNotInstalledAlert = false

// MARK: - Presentation Logic
    func presentLoading() {
        state = .loading
    }

    func presentLoad(response: LocationsList.Load.Response) {
        switch response.result {
        case .success(let locations):
            state = .loaded(locations)
        case .failure(let error):
            state = .error(error.localizedDescription)
        }
    }

    func presentOpenResult(response: LocationsList.OpenLocation.Response) {
        if !response.success {
            isShowingNotInstalledAlert = true
        }
    }
}
