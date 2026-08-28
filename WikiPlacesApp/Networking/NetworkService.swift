//
//  NetworkService.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import Foundation

// MARK: - Error
enum NetworkError: Error {
    case invalidURL
    case networkError(String)
    case invalidResponse
    case decodingError(String)
}

// MARK: - Protocol
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from url: URL) async throws -> T
}

// MARK: - Implementation
struct NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T>(from url: URL) async throws -> T where T: Decodable {
        var request = URLRequest(url: url)
        // Always bypass cache so the list reflects the latest remote data on each launch
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}
