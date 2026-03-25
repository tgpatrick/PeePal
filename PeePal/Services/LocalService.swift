//
//  LocalService.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import Foundation

protocol LocalService {
    associatedtype ModelType

    func save(_ models: [ModelType]) async throws
    func fetchAll() async throws -> [ModelType]
    func deleteAll() async throws
}

extension LocalService {
    func clear() async throws {
        try await deleteAll()
    }
}
