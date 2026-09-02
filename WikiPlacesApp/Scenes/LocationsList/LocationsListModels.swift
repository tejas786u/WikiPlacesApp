//
//  LocationsListModels.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

// MARK: - ListLoading States
enum LocationsListState: Equatable {
    case idle
    case loading
    case loaded([Location])
    case error(String)
}

// MARK: - VIP Models
enum LocationsList {
    enum Load {
        struct Response {
            let result: Result<[Location], Error>
        }
    }

    enum OpenLocation {
        struct Request {
            let location: Location
        }
        struct Response {
            let success: Bool
        }
    }
}
