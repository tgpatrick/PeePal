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
        
//        // If local is empty or failed, fetch from network
//        let networkRestrooms = try await networkService.fetchAllRestrooms()
//        logger.info("Fetched \(networkRestrooms.count) restrooms from network")
//        
//        // Save to local storage
//        try await localService.save(networkRestrooms)
//        logger.info("Saved restrooms to local storage")
//        
//        return networkRestrooms
        return []
    }
    
    func fetchRestrooms(near location: CLLocationCoordinate2D, page: Int = 1) async throws -> [Restroom] {
        // For now, delegate to network service
        // In future, could implement local search or caching
        try await networkService.fetchRestrooms(near: location, page: page)
    }
    
    func initializeFromBundleIfNeeded() async throws {
        let localRestrooms = try await localService.fetchAllRestrooms()
        if localRestrooms.isEmpty {
            let bundleRestrooms = try localService.loadRestroomsFromBundle()
            try await localService.save(bundleRestrooms)
            logger.info("Initialized local data from bundle with \(bundleRestrooms.count) restrooms")
        }
    }
}
