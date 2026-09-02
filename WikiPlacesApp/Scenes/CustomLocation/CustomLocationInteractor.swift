//
//  CustomLocationInteractor.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

// MARK: - Business Logic Protocol
protocol CustomLocationBusinessLogic {
    func validate(request: CustomLocation.Validate.Request)
    func open(request: CustomLocation.Open.Request) async
}

// MARK: - Data Store
protocol CustomLocationDataStore {
    var validatedLocation: Location? { get }
}

@MainActor
final class CustomLocationInteractor: CustomLocationBusinessLogic, CustomLocationDataStore {

// MARK: - Validation Ranges
    let latitudeRange: ClosedRange<Double> = -90...90
    let longitudeRange: ClosedRange<Double> = -180...180

// MARK: - Dependencies
    var presenter: CustomLocationPresentationLogic?
    private let deepLinkWorker: DeepLinkWorkerProtocol

// MARK: - Data Store
    private(set) var validatedLocation: Location?

// MARK: - Init
    init(deepLinkWorker: DeepLinkWorkerProtocol) {
        self.deepLinkWorker = deepLinkWorker
    }

// MARK: - Business Logic
    func validate(request: CustomLocation.Validate.Request) {
        let latResult = validate(request.latitudeText, range: latitudeRange, fieldName: "Latitude")
        let lonResult = validate(request.longitudeText, range: longitudeRange, fieldName: "Longitude")

        if let latitude = latResult.value, let longitude = lonResult.value {
            let trimmedName = request.name.trimmingCharacters(in: .whitespacesAndNewlines)
            validatedLocation = Location(name: trimmedName.isEmpty ? nil : trimmedName, latitude: latitude, longitude: longitude)
        } else {
            validatedLocation = nil
        }

        presenter?.presentValidation(response: CustomLocation.Validate.Response(
            latitudeError: latResult.error,
            longitudeError: lonResult.error
        ))
    }

    func open(request: CustomLocation.Open.Request) async {
        guard let location = validatedLocation else { return }
        let success = await deepLinkWorker.openDeepLink(for: location)
        presenter?.presentOpenResult(response: CustomLocation.Open.Response(success: success))
    }

// MARK: - Private
    private func validate(_ text: String, range: ClosedRange<Double>, fieldName: String) -> (value: Double?, error: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return (nil, "\(fieldName) is required.")
        }
        guard let value = Double(trimmed) else {
            return (nil, "\(fieldName) must be a number.")
        }
        guard range.contains(value) else {
            return (nil, "\(fieldName) must be between \(Int(range.lowerBound)) and \(Int(range.upperBound)).")
        }
        return (value, nil)
    }
}
