//
//  RestroomLocalService.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import Foundation
import SwiftData
import OSLog
import MapKit

struct RestroomLocalService: RestroomLocalServiceProtocol, LocalService {
    typealias ModelType = Restroom

    private let modelContext: ModelContext
    private let logger = Logger.for(RestroomLocalService.self)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @MainActor
    func save(_ models: [Restroom]) async throws {
        let entities = models.map { RestroomEntity(restroom: $0) }

        for entity in entities {
            modelContext.insert(entity)
        }

        try modelContext.save()

        logger.info("Saved \(models.count) restrooms to local datastore")
    }

    @MainActor
    func fetchAll() async throws -> [Restroom] {
        let entities: [RestroomEntity] = try modelContext.fetch(FetchDescriptor<RestroomEntity>())
        return entities.map { $0.asRestroom }
    }

    func fetchAllRestrooms() async throws -> [Restroom] {
        try await fetchAll()
    }
    
    func deleteAll() async throws {
        try await clearRestrooms()
    }

    @MainActor
    func clearRestrooms() async throws {
        let entities: [RestroomEntity] = try modelContext.fetch(FetchDescriptor<RestroomEntity>())
        for entity in entities {
            modelContext.delete(entity)
        }

        try modelContext.save()
        logger.info("Cleared all restrooms from local datastore")
    }
    
    func loadRestroomsFromBundle() throws -> [Restroom] {
        guard let url = Bundle.main.url(forResource: "Restrooms", withExtension: "json") else {
            throw NetworkError.missingResource
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Restroom].self, from: data)
    }

    @MainActor
    func fetchRestrooms(in region: MKCoordinateRegion) async throws -> [Restroom] {
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2

        let predicate = #Predicate<RestroomEntity> {
            $0.latitude >= minLat && $0.latitude <= maxLat &&
            $0.longitude >= minLon && $0.longitude <= maxLon
        }

        let descriptor = FetchDescriptor<RestroomEntity>(predicate: predicate)
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.asRestroom }
    }

    @MainActor
    func searchRestrooms(matching query: String, limit: Int = 25) async throws -> [Restroom] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
//        let lowercased = trimmed.lowercased()

        // Build a SwiftData predicate to search across common textual fields.
        let predicate = #Predicate<RestroomEntity> { entity in
            (entity.name?.localizedStandardContains(trimmed) ?? false) ||
//            (entity.street?.localizedLowercase.contains(lowercased) ?? false) ||
            (entity.city?.localizedStandardContains(trimmed) ?? false)
//            (entity.state?.localizedLowercase.contains(lowercased) ?? false)
        }

        var descriptor = FetchDescriptor<RestroomEntity>(predicate: predicate)
        descriptor.fetchLimit = limit
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.asRestroom }
    }
}
