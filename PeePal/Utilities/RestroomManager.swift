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
    private let networkService: RestroomNetworkService
    private let localService: RestroomLocalService
    private let logger = Logger.for(RestroomManager.self)
    
    @MainActor
    init(modelContext: ModelContext,
         networkService: RestroomNetworkService = .shared) {
        self.networkService = networkService
        self.localService = RestroomLocalService(modelContext: modelContext)
    }
    
    func fetchAllLocalRestrooms() async throws -> [Restroom] {
        // Try to fetch from local storage first
        do {
            let localRestrooms = try await localService.fetchAll()
            if !localRestrooms.isEmpty {
                logger.info("Fetched \(localRestrooms.count) restrooms from local storage")
                return localRestrooms
            }
        } catch {
            logger.warning("Failed to fetch from local storage: \(error)")
        }
        
        // If local is empty, try to load from bundle as fallback
        do {
            let bundleRestrooms = try await localService.loadRestroomsFromBundle()
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
        try await networkService.fetchRestrooms(
            near: location,
            page: page,
            filters: FilterService().getState()
        )
    }
    
    func searchRemoteRestrooms(matching query: String, limit: Int = 25) async throws -> [Restroom] {
        try await networkService.searchRestrooms(matching: query, limit: limit)
    }
    
    func initializeFromBundleIfNeeded() async throws {
        let localRestrooms = try await localService.fetchAll()
        if localRestrooms.count < 2100 { // That's how many restrooms are in the JSON
            let bundleRestrooms = try await localService.loadRestroomsFromBundle()
            try await localService.save(bundleRestrooms)
            logger.info("Initialized local data from bundle with \(bundleRestrooms.count) restrooms")
        }
    }
    
    func fetchRestrooms(in region: MKCoordinateRegion) async throws -> [Restroom] {
        try await localService.fetchRestrooms(in: region)
    }
    
    func searchLocalRestrooms(matching query: String, limit: Int = 25) async throws -> [Restroom] {
        try await localService.searchRestrooms(matching: query, limit: limit)
    }
    
    // Save restrooms to local storage (delegates to local service)
    func save(_ restrooms: [Restroom]) async throws {
        try await localService.save(restrooms)
    }
}

