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
    changingTable: true,
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
    changingTable: true,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)

let unisexRestroom = Restroom(
    id: 3,
    name: "Boring Restroom",
    street: "123 Hello World Ln",
    accessible: false,
    unisex: true,
    changingTable: true,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)

let changingTableRestroom = Restroom(
    id: 4,
    name: "Changing Table Restroom",
    street: "123 Hello World Ln",
    accessible: false,
    unisex: false,
    changingTable: true,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)

let boringRestroom = Restroom(
    id: 5,
    name: "Boring Restroom",
    street: "123 Hello World Ln",
    accessible: false,
    unisex: false,
    changingTable: false,
    distance: 1.0,
    downvote: 0,
    upvote: 1,
    latitude: 37.7749,
    longitude: -122.4194)
