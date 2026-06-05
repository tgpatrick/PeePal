//
//  RestroomServiceProtocol.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import CoreLocation
import Foundation
import MapKit

protocol RestroomNetworkServiceProtocol {
    func fetchRestrooms(
        near location: CLLocationCoordinate2D,
        page: Int,
        filters: FilterState
    ) async throws -> [Restroom]
    func fetchAllRestrooms() async throws -> [Restroom]
}

protocol RestroomLocalServiceProtocol {
    func save(_ restrooms: [Restroom]) async throws
    func fetchAllRestrooms() async throws -> [Restroom]
    func clearRestrooms() async throws
    func loadRestroomsFromBundle() throws -> [Restroom]
    func fetchRestrooms(in: MKCoordinateRegion) async throws -> [Restroom]
    func searchRestrooms(matching query: String, limit: Int) async throws -> [Restroom]
}
