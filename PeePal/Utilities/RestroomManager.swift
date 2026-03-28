//
//  RestroomManager.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import Foundation
import MapKit
import OSLog
import SwiftData

struct RestroomManager {
    private let networkService: RestroomNetworkServiceProtocol
    private let localService: RestroomLocalServiceProtocol
    private let logger = Logger.for(RestroomManager.self)
    
    init(modelContext: ModelContext,
         networkService: RestroomNetworkServiceProtocol = RestroomNetworkService.shared) {
        self.networkService = networkService
        self.localService = RestroomLocalService(modelContext: modelContext)
    }
    
    func fetchAllRestrooms() async throws -> [Restroom] {
        // Try to fetch from local storage first
        do {
            let localRestrooms = try await localService.fetchAllRestrooms()
            if !localRestrooms.isEmpty {
                logger.info("Fetched \(localRestrooms.count) restrooms from local storage")
                return localRestrooms
            }
        } catch {
            logger.warning("Failed to fetch from local storage: \(error)")
        }
        
        // If local is empty, try to load from bundle as fallback
        do {
            let bundleRestrooms = try localService.loadRestroomsFromBundle()
            try await localService.save(bundleRestrooms)
            logger.info("Loaded \(bundleRestrooms.count) restrooms from bundle as fallback")
            return bundleRestrooms
        } catch {
            logger.error("Failed to load from bundle: \(error)")
        }
        
        logger.warning("No restrooms available from any source")
        return []
    }
    
    func fetchRestrooms(near location: CLLocationCoordinate2D, page: Int = 1) async throws -> [Restroom] {
        try await networkService.fetchRestrooms(near: location, page: page)
    }
    
    func initializeFromBundleIfNeeded() async throws {
        let localRestrooms = try await localService.fetchAllRestrooms()
        if localRestrooms.count < 2100 { // That's how many restrooms are in the JSON
            let bundleRestrooms = try localService.loadRestroomsFromBundle()
            try await localService.save(bundleRestrooms)
            logger.info("Initialized local data from bundle with \(bundleRestrooms.count) restrooms")
        }
    }
    
    func fetchRestrooms(in region: MKCoordinateRegion) async throws -> [Restroom] {
        try await localService.fetchRestrooms(in: region)
    }
    
    // Save restrooms to local storage (delegates to local service)
    func save(_ restrooms: [Restroom]) async throws {
        try await localService.save(restrooms)
    }
}
