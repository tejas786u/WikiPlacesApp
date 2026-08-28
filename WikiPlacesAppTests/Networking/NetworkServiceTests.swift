//
//  NetworkServiceTests.swift
//  WikiPlacesAppTests
//
//  Created by Tejas Patel on 28/08/26.
//

import XCTest
@testable import WikiPlacesApp

@MainActor
final class NetworkServiceTests: XCTestCase {

    private var sut: NetworkService!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut = NetworkService(session: URLSession(configuration: config))
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private struct SimpleResponse: Decodable, Equatable {
        let name: String
    }

    private func makeURL() -> URL {
        URL(string: "https://test.example.com/data")!
    }

    private func makeHTTPResponse(statusCode: Int, url: URL? = nil) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url ?? makeURL(),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    // MARK: - Successful fetch

    func testFetch_ValidJSONAnd200_ReturnsDecodedObject() async throws {
        MockURLProtocol.requestHandler = { [self] _ in
            let data = #"{"name":"Amsterdam"}"#.data(using: .utf8)!
            return (makeHTTPResponse(statusCode: 200), data)
        }

        let result: SimpleResponse = try await sut.fetch(from: makeURL())

        XCTAssertEqual(result.name, "Amsterdam")
    }

    func testFetch_ValidJSONAnd200_DecodesComplexObject() async throws {
        let locations = [
            ["name": "Amsterdam", "lat": 52.3676, "long": 4.9041] as [String: Any]
        ]
        let json = try JSONSerialization.data(withJSONObject: ["locations": locations])
        MockURLProtocol.requestHandler = { [self] _ in
            return (makeHTTPResponse(statusCode: 200), json)
        }

        let result: LocationResponse = try await sut.fetch(from: makeURL())

        XCTAssertEqual(result.locations.count, 1)
        XCTAssertEqual(result.locations[0].name, "Amsterdam")
    }

    // MARK: - HTTP error responses

    func testFetch_404Response_ThrowsInvalidResponse() async {
        MockURLProtocol.requestHandler = { [self] _ in
            return (makeHTTPResponse(statusCode: 404), Data())
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected NetworkError.invalidResponse")
        } catch NetworkError.invalidResponse {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetch_500Response_ThrowsInvalidResponse() async {
        MockURLProtocol.requestHandler = { [self] _ in
            return (makeHTTPResponse(statusCode: 500), Data())
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected NetworkError.invalidResponse")
        } catch NetworkError.invalidResponse {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetch_201Response_ThrowsInvalidResponse() async {
        MockURLProtocol.requestHandler = { [self] _ in
            return (makeHTTPResponse(statusCode: 201), #"{"name":"x"}"#.data(using: .utf8)!)
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected NetworkError.invalidResponse")
        } catch NetworkError.invalidResponse {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Decoding errors

    func testFetch_InvalidJSON_ThrowsDecodingError() async {
        MockURLProtocol.requestHandler = { [self] _ in
            return (makeHTTPResponse(statusCode: 200), "not json at all".data(using: .utf8)!)
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected a decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError, "Expected DecodingError, got \(error)")
        }
    }

    func testFetch_MissingRequiredField_ThrowsDecodingError() async {
        MockURLProtocol.requestHandler = { [self] _ in
            // "name" key is missing
            return (makeHTTPResponse(statusCode: 200), "{}".data(using: .utf8)!)
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected a decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    // MARK: - Network-level errors

    func testFetch_NetworkConnectionFailure_PropagatesURLError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected URLError")
        } catch {
            XCTAssertTrue(error is URLError, "Expected URLError, got \(error)")
        }
    }

    func testFetch_Timeout_PropagatesURLError() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        do {
            let _: SimpleResponse = try await sut.fetch(from: makeURL())
            XCTFail("Expected URLError")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .timedOut)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Request configuration

    func testFetch_UsesCacheIgnoringLocalCachePolicy() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (self.makeHTTPResponse(statusCode: 200), #"{"name":"x"}"#.data(using: .utf8)!)
        }

        let _: SimpleResponse = try await sut.fetch(from: makeURL())

        XCTAssertEqual(capturedRequest?.cachePolicy, .reloadIgnoringLocalCacheData)
    }

    func testFetch_SendsRequestToCorrectURL() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (self.makeHTTPResponse(statusCode: 200), #"{"name":"x"}"#.data(using: .utf8)!)
        }
        let url = URL(string: "https://api.example.com/locations")!

        let _: SimpleResponse = try await sut.fetch(from: url)

        XCTAssertEqual(capturedRequest?.url, url)
    }
}
