//
//  RestroomService.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation
import CoreLocation
import OSLog

class RestroomService_old {
    private static let baseURL = "https://www.refugerestrooms.org/api/v1/restrooms"
    private static let logger = Logger()

    static func fetchRestrooms(near location: CLLocationCoordinate2D, page: Int = 1) async throws -> [Restroom] {
        let latitude = location.latitude
        let longitude = location.longitude
        let urlString = "\(baseURL)/by_location.json?page=\(page)&per_page=\(30)&lat=\(latitude)&lng=\(longitude)"
        let session = URLSession(configuration: .default)

        logger.info("Fetching restrooms:\nlat: \(latitude)\nlong: \(longitude)\npage: \(page)")

        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL")
            throw NetworkError_old.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Unknown response from backend")
                throw NetworkError_old.unknownError
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("Backend returned non-200 response")
                throw NetworkError_old.serverError(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder().decode([Restroom].self, from: data)
            } catch {
                logger.error("Decoding error")
                throw NetworkError_old.decodingError(error)
            }
        } catch let error as NetworkError_old {
            logger.error("\(error)")
            throw error
        } catch {
            logger.error("\(error)")
            throw NetworkError.networkError(error)
        }
    }
    
    static func fetchAllRestrooms() async throws -> [Restroom] {
        var restrooms = [Restroom]()
        var page = 1
        repeat {
            guard let url = URL(string: baseURL + "?page=\(page)" + "&per_page=100") else {
                logger.error("Invalid URL")
                throw NetworkError.invalidURL
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            if let string = String(data: data, encoding: .utf8) {
                print(string)
            }
            if let decodedRestrooms = try? JSONDecoder().decode([Restroom].self, from: data) {
                restrooms += decodedRestrooms
            } else {
                break
            }
            page += 1
        } while page < 30
        if page == 30 {
            print("Reached page limit")
        }
        return restrooms
    }
}

extension RestroomService_old {
    static func loadRestroomsFromBundle() throws -> [Restroom] {
        let decoder = JSONDecoder()

        guard let url = Bundle.main.url(forResource: "Restrooms", withExtension: "json") else {
            throw NetworkError_old.missingResource
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([Restroom].self, from: data)
        } catch {
            throw NetworkError_old.decodingError(error)
        }
    }
}
