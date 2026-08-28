//
//  DLOpener.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation
import UIKit

// MARK: - Protocol
protocol DeepLinkOpenerProtocol {
    @MainActor
    func openDeepLink(for location: Location) async -> Bool
}

// MARK: - Implementation
struct WikipediaOpener: DeepLinkOpenerProtocol {
    let deepLink: DeepLinkCreateProtocol

    @MainActor
    func openDeepLink(for location: Location) async -> Bool {
        guard let url = deepLink.createDeepLink(for: location) else {
            return false
        }
        guard UIApplication.shared.canOpenURL(url) else {
            return false
        }
        // withCheckedContinuation bridges the callback-based UIApplication.open into async/await
        return await withCheckedContinuation { continuation in
            UIApplication.shared.open(url, options: [:]) { success in
                continuation.resume(returning: success)
            }
        }
    }
}
