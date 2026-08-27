//
//  DLBuilder.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

protocol DeepLinkServiceProtocol {
    func createDeepLink(for location: Location) -> URL?
}

class WikipediaDeepLink: DeepLinkServiceProtocol {
    func createDeepLink(for location: Location) -> URL? {
        var components = URLComponents()
        components.scheme = WikipediaConfig.scheme
        components.host = WikipediaConfig.host
        components.queryItems = [
            URLQueryItem(name: WikipediaConfig.Queryparam.latitude, value: String(location.latitude)),
            URLQueryItem(name: WikipediaConfig.Queryparam.longitude, value: String(location.longitude))
        ]
        return components.url
    }
}
