//
//  RestroomEntity.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import SwiftData
import CoreLocation

@Model
final class RestroomEntity {
    @Attribute(.unique) var id: Int
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
    
    var allText: String

    init(
        id: Int,
        name: String? = nil,
        street: String? = nil,
        city: String? = nil,
        state: String? = nil,
        accessible: Bool,
        unisex: Bool,
        changingTable: Bool,
        distance: Float? = nil,
        comment: String? = nil,
        directions: String? = nil,
        downvote: Int,
        upvote: Int,
        latitude: Double,
        longitude: Double
    ) {
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
        self.allText = [name, street, city, state, comment, directions]
            .compactMap(\.self)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    convenience init(restroom: Restroom) {
        self.init(
            id: restroom.id,
            name: restroom.name,
            street: restroom.street,
            city: restroom.city,
            state: restroom.state,
            accessible: restroom.accessible,
            unisex: restroom.unisex,
            changingTable: restroom.changingTable,
            distance: restroom.distance,
            comment: restroom.comment,
            directions: restroom.directions,
            downvote: restroom.downvote,
            upvote: restroom.upvote,
            latitude: restroom.latitude,
            longitude: restroom.longitude
        )
    }

    var asRestroom: Restroom {
        Restroom(
            id: id,
            name: name,
            street: street,
            city: city,
            state: state,
            accessible: accessible,
            unisex: unisex,
            changingTable: changingTable,
            distance: distance,
            comment: comment,
            directions: directions,
            downvote: downvote,
            upvote: upvote,
            latitude: latitude,
            longitude: longitude
        )
    }
}


#if DEBUG
@MainActor
class DataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: RestroomEntity.self, configurations: config)

            for i in 1...9 {
                let restroom = RestroomEntity(restroom: exampleRestroom)
                container.mainContext.insert(restroom)
            }

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
#endif // DEBUG
