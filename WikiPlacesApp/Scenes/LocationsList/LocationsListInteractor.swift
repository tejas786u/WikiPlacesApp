//
//  LocationsListInteractor.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

// MARK: - Business Logic Protocol
protocol LocationsListBusinessLogic {
    func loadIfNeeded() async
    func retry() async
    func refresh() async
    func open(location: Location) async
}

// MARK: - Data Store
protocol LocationsListDataStore {
    var locations: [Location] { get }
}

@MainActor
final class LocationsListInteractor: LocationsListBusinessLogic, LocationsListDataStore {

// MARK: - Internal Phase (mirrors the previous ViewModel's idle/loading/loaded/error guard)
    private enum Phase: Equatable {
        case idle, loading, loaded, error
    }

// MARK: - Dependencies
    var presenter: LocationsListPresentationLogic?
    private let worker: LocationsWorkerProtocol
    private let deepLinkWorker: DeepLinkWorkerProtocol

// MARK: - Data Store
    private(set) var locations: [Location] = []
    private var phase: Phase = .idle

// MARK: - Init
    init(worker: LocationsWorkerProtocol, deepLinkWorker: DeepLinkWorkerProtocol) {
        self.worker = worker
        self.deepLinkWorker = deepLinkWorker
    }

// MARK: - Business Logic
    func loadIfNeeded() async {
        guard phase == .idle else { return }
        await performFetch()
    }

    func retry() async {
        await performFetch()
    }

    func refresh() async {
        await performFetch()
    }

    func open(location: Location) async {
        let success = await deepLinkWorker.openDeepLink(for: location)
        presenter?.presentOpenResult(response: LocationsList.OpenLocation.Response(success: success))
    }

// MARK: - Private
    private func performFetch() async {
        phase = .loading
        presenter?.presentLoading()
        do {
            let result = try await worker.fetchLocations()
            locations = result
            phase = .loaded
            presenter?.presentLoad(response: LocationsList.Load.Response(result: .success(result)))
        } catch {
            phase = .error
            presenter?.presentLoad(response: LocationsList.Load.Response(result: .failure(error)))
        }
    }
}
