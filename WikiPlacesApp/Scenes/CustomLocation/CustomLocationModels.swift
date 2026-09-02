//
//  CustomLocationModels.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import Foundation

enum CustomLocation {
    enum Validate {
        struct Request {
            let name: String
            let latitudeText: String
            let longitudeText: String
        }
        struct Response {
            let latitudeError: String?
            let longitudeError: String?
        }
    }

    enum Open {
        struct Request {}
        struct Response {
            let success: Bool
        }
    }
}
