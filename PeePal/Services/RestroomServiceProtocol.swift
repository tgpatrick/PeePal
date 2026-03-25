//
//  RestroomServiceProtocol.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation
import CoreLocation

protocol RestroomNetworkServiceProtocol {
    func fetchRestrooms(near location: CLLocationCoordinate2D, page: Int) async throws -> [Restroom]
    func fetchAllRestrooms() async throws -> [Restroom]
}

protocol RestroomLocalServiceProtocol {
    func save(_ restrooms: [Restroom]) async throws
    func fetchAllRestrooms() async throws -> [Restroom]
    func clearRestrooms() async throws
    func loadRestroomsFromBundle() throws -> [Restroom]
}


