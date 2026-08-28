//
//  DLBuilder.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

// MARK: - Protocol
protocol DeepLinkCreateProtocol {
    func createDeepLink(for location: Location) -> URL?
}

// MARK: - Implementation
struct WikipediaDeepLink: DeepLinkCreateProtocol {
    func createDeepLink(for location: Location) -> URL? {
        var components = URLComponents()
        components.scheme = WikipediaConfig.scheme
        components.host = WikipediaConfig.host
        var items = [
            URLQueryItem(name: WikipediaConfig.QueryParam.latitude, value: String(location.latitude)),
            URLQueryItem(name: WikipediaConfig.QueryParam.longitude, value: String(location.longitude))
        ]
        let trimmedName = location.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedName, !trimmedName.isEmpty {
            items.append(URLQueryItem(name: "name", value: trimmedName))
        }
        components.queryItems = items
        return components.url
    }
}
