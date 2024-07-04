//
//  RestroomServiceError.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .networkError(let error):
            return "A network error occurred: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned an error: HTTP \(statusCode)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
