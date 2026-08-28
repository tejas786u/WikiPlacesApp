//
//  CustomLocationViewModel.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 28/08/26.
//

import Foundation
import Combine

@MainActor
final class CustomLocationViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var latitudeText: String = ""
    @Published var longitudeText: String = ""
    @Published private(set) var latitudeError: String?
    @Published private(set) var longitudeError: String?

    let latitudeRange: ClosedRange<Double> = -90...90
    let longitudeRange: ClosedRange<Double> = -180...180

    /// Validates the current field values, publishing per-field error messages as a side
    /// effect. Returns the parsed coordinate (and optional trimmed name) only when both
    /// fields are valid.
    @discardableResult
    func validatedCoordinate() -> Location? {
        let latResult = self.validate(latitudeText, range: self.latitudeRange, fieldName: "Latitude")
        let lonResult = self.validate(longitudeText, range: self.longitudeRange, fieldName: "Longitude")
        latitudeError = latResult.error
        longitudeError = lonResult.error
        
        guard let latitude = latResult.value, let longitude = lonResult.value else {
            return nil
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return Location(name: trimmedName.isEmpty ? nil : trimmedName, latitude: latitude, longitude: longitude)
    }

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
