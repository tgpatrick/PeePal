//
//  SearchRestroom.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import Foundation

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
