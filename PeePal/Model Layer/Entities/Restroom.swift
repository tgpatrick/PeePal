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
    var distance: Float?
    var comment: String?
    var directions: String?
    var downvote: Int
    var upvote: Int
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func getCoordinates() -> CLLocationCoordinate2D {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(latitude),
            longitude: CLLocationDegrees(longitude))
        return coordinates
    }
}

extension Restroom: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

struct RestroomCluster {
    let restrooms: [Restroom]
    let center: CLLocationCoordinate2D
    var size: Int {
        restrooms.count
    }

    internal init(restrooms: [Restroom]) {
        self.restrooms = restrooms
        let intoCoord = CLLocationCoordinate2D(latitude: 0.0,longitude: 0.0)
        let factor = 1.0 / Double(restrooms.count)
        self.center = restrooms.reduce(intoCoord) { average, restroom in
            let itemCoord = restroom.coordinate
            let lat = itemCoord.latitude * factor
            let lon = itemCoord.longitude * factor
            return CLLocationCoordinate2D(latitude: average.latitude + lat, longitude: average.longitude + lon)
        }
    }
}

extension RestroomCluster: Hashable, Identifiable {
    var id: String {
        String(describing: center.latitude) + String(describing: center.longitude)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(center.latitude)
        hasher.combine(center.longitude)
    }

    static func == (lhs: RestroomCluster, rhs: RestroomCluster) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude
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
