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
    var changingTable: Bool
    var distance: Float?
    var comment: String?
    var directions: String?
    var downvote: Int
    var upvote: Int
    var latitude: Double
    var longitude: Double

    init(id: Int, name: String? = nil, street: String? = nil, city: String? = nil, state: String? = nil, accessible: Bool, unisex: Bool, changingTable: Bool, distance: Float? = nil, comment: String? = nil, directions: String? = nil, downvote: Int, upvote: Int, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.accessible = accessible
        self.unisex = unisex
        self.changingTable = changingTable
        self.distance = distance
        self.comment = comment
        self.directions = directions
        self.downvote = downvote
        self.upvote = upvote
        self.latitude = latitude
        self.longitude = longitude
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case street
        case city
        case state
        case accessible
        case unisex
        case changing_table
        case distance
        case comment
        case directions
        case downvote
        case upvote
        case latitude
        case longitude
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.street = try container.decodeIfPresent(String.self, forKey: .street)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.accessible = try container.decode(Bool.self, forKey: .accessible)
        self.unisex = try container.decode(Bool.self, forKey: .unisex)
        self.changingTable = try container.decode(Bool.self, forKey: .changing_table)
        self.distance = try container.decodeIfPresent(Float.self, forKey: .distance)

        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if comment == "" { comment = nil }
        self.directions = try container.decodeIfPresent(String.self, forKey: .directions)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if directions == "" { directions = nil }

        self.downvote = try container.decode(Int.self, forKey: .downvote)
        self.upvote = try container.decode(Int.self, forKey: .upvote)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.self, forKey: .id)
        try container.encodeIfPresent(name.self, forKey: .name)
        try container.encodeIfPresent(street.self, forKey: .street)
        try container.encodeIfPresent(city.self, forKey: .city)
        try container.encodeIfPresent(state.self, forKey: .state)
        try container.encode(accessible.self, forKey: .accessible)
        try container.encode(unisex.self, forKey: .unisex)
        try container.encode(changingTable.self, forKey: .changing_table)
        try container.encodeIfPresent(distance.self, forKey: .distance)
        try container.encodeIfPresent(comment.self, forKey: .comment)
        try container.encodeIfPresent(directions.self, forKey: .directions)
        try container.encode(downvote.self, forKey: .downvote)
        try container.encode(upvote.self, forKey: .upvote)
        try container.encode(latitude.self, forKey: .latitude)
        try container.encode(longitude.self, forKey: .longitude)
    }

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

    static func == (lhs: Restroom, rhs: Restroom) -> Bool {
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
}

struct RestroomCluster {
    let restrooms: [Restroom]
    let center: CLLocationCoordinate2D
    var size: Int {
        restrooms.count
    }
    var isSingle: Bool {
        restrooms.count == 1
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
