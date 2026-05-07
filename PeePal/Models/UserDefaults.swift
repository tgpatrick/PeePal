//
//  UserDefaults.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import Foundation

enum Filter: String {
    case accessible = "accessFilter"
    case changingTable = "tableFilter"
    case unisex = "unisexFilter"
}

enum Setting: String {
    case colorScheme = "colorScheme"
    case directionsProvider = "directionsProvider"
    case liquidGlassDisabled = "liquidGlassDisabled"
    case mapMode = "mapMode"
    case offlineMode = "offlineMode"
}
