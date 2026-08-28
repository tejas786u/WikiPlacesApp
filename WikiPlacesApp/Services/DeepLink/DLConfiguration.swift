//
//  DLConfiguration.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

enum WikipediaConfig {
    static let scheme = "wikipedia"
    static let host = "places"

    enum QueryParam {
        static let latitude = "lat"
        static let longitude = "lon"
    }
}
