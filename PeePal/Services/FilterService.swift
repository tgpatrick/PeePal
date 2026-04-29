//
//  FilterService.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/29/26.
//

import Foundation

struct FilterService: Sendable, Equatable {
    var accessible: Bool { UserDefaults.standard.bool(forKey: Filter.accessible.rawValue) }
    var unisex: Bool { UserDefaults.standard.bool(forKey: Filter.unisex.rawValue) }
    var changingTable: Bool { UserDefaults.standard.bool(forKey: Filter.changingTable.rawValue) }
    
    func getState() -> FilterState {
        FilterState(accessible: accessible, unisex: unisex, changingTable: changingTable)
    }
}

struct FilterState: Sendable, Equatable {
    var accessible: Bool
    var unisex: Bool
    var changingTable: Bool
}
