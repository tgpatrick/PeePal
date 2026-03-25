//
//  RestroomServiceError.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation

enum NetworkError_old: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknownError
    case locationError(Error)
    case locationNotAvailable
    case missingResource

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
        case .locationError(let error):
            return "A location error occurred: \(error.localizedDescription)"
        case .locationNotAvailable:
            return "Unable to determine your location. Please check your location settings."
        case .missingResource:
            return "The resource you are looking for does not exist."
        }
    }
}
