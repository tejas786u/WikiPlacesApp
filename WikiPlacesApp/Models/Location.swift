//
//  Location.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation
struct Location: Identifiable, Equatable {
    var id: UUID
    let name: String?
    let latitude: Double
    let longitude: Double
    
    init(id: UUID = UUID(), name: String?, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var displayName: String {
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return Self.coordinateString(latitude: latitude, longitude: longitude)
    }

    var coordinateString: String {
        Self.coordinateString(latitude: latitude, longitude: longitude)
    }

    static func coordinateString(latitude: Double, longitude: Double) -> String {
        String(format: "Lat: %.4f, Lon: %.4f", latitude, longitude)
    }
}

extension Location: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "long"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try container.decodeIfPresent(String.self, forKey: .name),
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        )
    }
}

struct LocationResponse : Decodable {
    let locations: [Location]
}
