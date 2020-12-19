//
//  ConcreteStructs.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import Foundation

let exampleRestroom = Restroom(
    id: 1,
    name: "Example Restroom",
    street: "123 Hello World Ln",
    city: "San Francisco",
    state: "California",
    accessible: true,
    unisex: true,
    changing_table: true,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)

let accessibleRestroom = Restroom(
    id: 2,
    name: "Accessible Restroom",
    street: "123 Hello World Ln",
    accessible: true,
    unisex: false,
    changing_table: true,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)

let unisexRestroom = Restroom(
    id: 3,
    name: "Unisex Restroom",
    street: "123 Hello World Ln",
    accessible: false,
    unisex: true,
    changing_table: true,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)
