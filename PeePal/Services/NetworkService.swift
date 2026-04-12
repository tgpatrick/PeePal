//
//  NetworkService.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import Foundation
import OSLog

protocol NetworkService {
    var baseURL: String { get }
    var session: URLSession { get }
    var decoder: JSONDecoder { get }
    var logger: Logger { get }
    var retryCount: Int { get }
    var retryDelay: TimeInterval { get }
}

extension NetworkService {
    var retryCount: Int { 2 }
    var retryDelay: TimeInterval { 0.4 }

    func makeURL(path: String? = nil, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            logger.error("Unable to parse baseURL: \(self.baseURL)")
            throw NetworkError.invalidURL
        }

        if let path = path, !path.isEmpty {
            let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
            components.path += normalizedPath
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            logger.error("Unable to build URL from components: \(components)")
            throw NetworkError.invalidURL
        }

        return url
    }

    func validateResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("Unknown response from backend: \(response)")
            throw NetworkError.unknownError
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error("Backend returned non-200 response: \(httpResponse.statusCode)")
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        return httpResponse
    }

    func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }

    func performDataTask(from url: URL) async throws -> Data {
        try await performDataTask(from: url, attempt: 0)
    }

    private func performDataTask(from url: URL, attempt: Int) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            _ = try validateResponse(response)
            return data
        } catch {
            if canRetry(error), attempt < retryCount {
                logger.warning("Retrying network request (attempt \(attempt + 1)) for URL: \(url) - error: \(error)")
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                return try await performDataTask(from: url, attempt: attempt + 1)
            }
            logger.error("Network request failed for URL: \(url) - error: \(error)")
            throw mapError(error)
        }
    }

    private func canRetry(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            let retryableCodes: [URLError.Code] = [.timedOut, .networkConnectionLost, .notConnectedToInternet, .internationalRoamingOff, .cannotFindHost, .cannotConnectToHost]
            return retryableCodes.contains(urlError.code)
        }

        return false
    }

    private func mapError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        if let urlError = error as? URLError {
            return .networkError(urlError)
        }

        return .unknownError
    }
}
