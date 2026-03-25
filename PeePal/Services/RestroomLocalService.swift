//
//  RestroomLocalService.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import Foundation
import SwiftData
import OSLog

struct RestroomLocalService: RestroomLocalServiceProtocol, LocalService {
    typealias ModelType = Restroom

    private let modelContext: ModelContext
    private let logger = Logger.for(RestroomLocalService.self)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ models: [Restroom]) async throws {
        let entities = models.map { RestroomEntity(restroom: $0) }

        for entity in entities {
            modelContext.insert(entity)
        }

        try modelContext.save()

        logger.info("Saved \(models.count) restrooms to local datastore")
    }

    func fetchAll() async throws -> [Restroom] {
        let entities: [RestroomEntity] = try modelContext.fetch(FetchDescriptor<RestroomEntity>())
        return entities.map { $0.asRestroom }
    }

    func fetchAllRestrooms() async throws -> [Restroom] {
        try await fetchAll()
    }

    func clearRestrooms() async throws {
        let entities: [RestroomEntity] = try modelContext.fetch(FetchDescriptor<RestroomEntity>())
        for entity in entities {
            modelContext.delete(entity)
        }

        try modelContext.save()
        logger.info("Cleared all restrooms from local datastore")
    }

    func deleteAll() async throws {
        try await clearRestrooms()
    }
    
    func loadRestroomsFromBundle() throws -> [Restroom] {
        guard let url = Bundle.main.url(forResource: "Restrooms", withExtension: "json") else {
            throw NetworkError.missingResource
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Restroom].self, from: data)
    }
}
