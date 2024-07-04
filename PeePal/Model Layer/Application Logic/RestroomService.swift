//
//  RestroomService.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation
import OSLog

class RestroomService {
    private static let baseURL = "https://www.refugerestrooms.org/api/v1/restrooms"
    private static let logger = Logger()

    static func fetchRestrooms(near latitude: Double, longitude: Double) async throws -> [Restroom] {
        logger.info("Fetching restrooms near coordinates:\nlat: \(latitude)\nlong:\(longitude)")
        let urlString = "\(baseURL)/by_location.json?lat=\(latitude)&lng=\(longitude)"

        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL")
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Unknown response from backend")
                throw NetworkError.unknownError
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("Backend returned non-200 response")
                throw NetworkError.serverError(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode([Restroom].self, from: data)
            } catch {
                logger.error("Decoding error")
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            logger.error("\(error)")
            throw error
        } catch {
            logger.error("\(error)")
            throw NetworkError.networkError(error)
        }
    }
}
