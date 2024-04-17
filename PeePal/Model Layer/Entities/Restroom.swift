//
//  Structs.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import SwiftUI
import MapKit

struct Restroom: Identifiable, Codable {
    var id: Int
    var name: String?
    var street: String?
    var city: String?
    var state: String?
    var accessible: Bool
    var unisex: Bool
    var changing_table: Bool
    var distance: Double?
    var comment: String?
    var directions: String?
    var downvote: Int
    var upvote: Int
    var latitude: Double
    var longitude: Double
    
    func getCoordinates() -> CLLocationCoordinate2D {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(latitude),
            longitude: CLLocationDegrees(longitude))
        return coordinates
    }
    
    func distanceFrom(_ location: CLLocationCoordinate2D) -> Double {
        let destination = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}

extension Restroom: Equatable, Hashable, Comparable {
    static func < (lhs: Restroom, rhs: Restroom) -> Bool {
        lhs.distance ?? 0 < rhs.distance ?? 0
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

struct SearchRestroom: Identifiable, Codable {
    var id: Int
    var name: String?
    var street: String?
    var city: String?
    var state: String?
    var accessible: Bool
    var unisex: Bool
    var directions: String?
    var comment: String?
    var downvote: Int
    var upvote: Int
    var latitude: Double
    var longitude: Double
    var changing_table: Bool
}

struct Response: Codable {
    var x_total_pages: Int
}
