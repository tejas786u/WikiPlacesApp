//
//  Location.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

// MARK: - Model
struct Location: Identifiable, Equatable {
    let id: UUID
    let name: String?
    let latitude: Double
    let longitude: Double

    init(id: UUID = UUID(), name: String?, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

// MARK: - Computed Properties
    var displayName: String {
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name
        }
        return "Unnamed Location"
    }

    var coordinateString: String {
        self.coordinateString(latitude: latitude, longitude: longitude)
    }

    func coordinateString(latitude: Double, longitude: Double) -> String {
        String(format: "Lat: %.4f, Lon: %.4f", latitude, longitude)
    }
}

// MARK: - Decodable
extension Location: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "long"  // JSON key is "long", not the conventional "lon"
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

// MARK: - Response Wrapper
struct LocationResponse: Decodable {
    let locations: [Location]
}
