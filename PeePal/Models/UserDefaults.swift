//
//  UserDefaults.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/26/26.
//

import Foundation

enum Filter: String {
    case accessible = "accessFilter"
    case changingTable = "tableFilter"
    case unisex = "unisexFilter"
}

enum Setting: String {
    case colorScheme = "colorScheme"
    case googleMapsEnabled = "googleMapsEnabled"
    case liquidGlassDisabled = "liquidGlassDisabled"
    case offlineMode = "offlineMode"
}
