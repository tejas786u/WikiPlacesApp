//
//  CustomLocationPresenter.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation
import Combine

// MARK: - Presentation Logic Protocol
protocol CustomLocationPresentationLogic {
    func presentValidation(response: CustomLocation.Validate.Response)
    func presentOpenResult(response: CustomLocation.Open.Response)
}

@MainActor
final class CustomLocationPresenter: CustomLocationPresentationLogic, ObservableObject {

// MARK: - Published ViewModel State
    @Published private(set) var latitudeError: String?
    @Published private(set) var longitudeError: String?
    @Published var isShowingNotInstalledAlert = false

// MARK: - Derived State
    var isValid: Bool {
        latitudeError == nil && longitudeError == nil
    }

// MARK: - Presentation Logic
    func presentValidation(response: CustomLocation.Validate.Response) {
        latitudeError = response.latitudeError
        longitudeError = response.longitudeError
    }

    func presentOpenResult(response: CustomLocation.Open.Response) {
        if !response.success {
            isShowingNotInstalledAlert = true
        }
    }
}
