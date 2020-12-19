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
    var latitude: Float
    var longitude: Float
    
    func getCoordinates() -> CLLocationCoordinate2D {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(latitude),
            longitude: CLLocationDegrees(longitude))
        return coordinates
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
    var latitude: Float
    var longitude: Float
    var changing_table: Bool
}

struct Response: Codable {
    var x_total_pages: Int
}
