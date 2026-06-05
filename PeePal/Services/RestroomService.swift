//
//  RestroomService.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation
import CoreLocation
import OSLog

protocol RestroomServiceProtocol {
    func fetchRestrooms(near location: CLLocationCoordinate2D, page: Int) async throws -> [Restroom]
    func fetchAllRestrooms() async throws -> [Restroom]
    func loadRestroomsFromBundle() throws -> [Restroom]
}

struct RestroomNetworkService: RestroomNetworkServiceProtocol, NetworkService {
    let baseURL = "https://www.refugerestrooms.org/api/v1/restrooms"
    let session: URLSession
    let decoder: JSONDecoder
    let logger = Logger.for(RestroomNetworkService.self)

    static let shared = RestroomNetworkService()

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    private func fetchPage(page: Int, perPage: Int) async throws -> [Restroom] {
        let url = try makeURL(queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ])

        let data = try await performDataTask(from: url)
        return try decode(data)
    }

    func fetchRestrooms(near location: CLLocationCoordinate2D, page: Int = 1) async throws -> [Restroom] {
        try Task.checkCancellation()

        logger.info("Fetching restrooms near (\(location.latitude), \(location.longitude)) page=\(page)")

        let url = try makeURL(path: "/by_location.json", queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lng", value: "\(location.longitude)")
        ])

        let data = try await performDataTask(from: url)
        return try decode(data)
    }

    func fetchAllRestrooms() async throws -> [Restroom] {
        try Task.checkCancellation()

        var restrooms = [Restroom]()
        let maxPages = 10
        var page = 1

        while page <= maxPages {
            try Task.checkCancellation()

            let pageRestrooms = try await fetchPage(page: page, perPage: 100)
            guard !pageRestrooms.isEmpty else { break }

            restrooms += pageRestrooms
            page += 1
        }

        if page > maxPages {
            logger.info("Reached maximum page limit: \(maxPages)")
        }

        return restrooms
    }

    func loadRestroomsFromBundle() throws -> [Restroom] {
        guard let url = Bundle.main.url(forResource: "Restrooms", withExtension: "json") else {
            throw NetworkError.missingResource
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([Restroom].self, from: data)
    }
}

