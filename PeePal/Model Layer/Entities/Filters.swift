//
//  Filters.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI

class Filters: ObservableObject {
    @Published var accessFilter = UserDefaults.standard.bool(forKey: "accessFilter")
    @Published var unisexFilter = UserDefaults.standard.bool(forKey: "unisexFilter")
//    @Published var tableFilter = UserDefaults.standard.bool(forKey: "tableFilter")
}
