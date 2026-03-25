//
//  NetworkError.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/21/26.
//

enum NetworkError: Error, CustomStringConvertible {
    case invalidURL
    case serverError(Int)
    case decodingError(Error)
    case unknownError
    case networkError(Error)
    case missingResource

    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unknownError:
            return "Unknown error"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .missingResource:
            return "Missing resource in bundle"
        }
    }
}
