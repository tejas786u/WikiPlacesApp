//
//  DLOpener.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation
import UIKit

protocol DeepLinkOpenerProtocol {
    func openDeepLink(for location: Location) async -> Bool
}

struct wikipediaOpener: DeepLinkOpenerProtocol {
    let wikipediaDeeplink: WikipediaDeepLink
    func openDeepLink(for location: Location) async -> Bool {
        if let url = wikipediaDeeplink.createDeepLink(for: location) {
            guard UIApplication.shared.canOpenURL(url) else {
                return false
            }
            return await withCheckedContinuation { continuation in
                UIApplication.shared.open(url, options: [:]) { success in
                    continuation.resume(returning: success)
                }
            }
        } else {
            return false
        }
    }
}
