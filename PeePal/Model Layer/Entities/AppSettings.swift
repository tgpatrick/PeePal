//
//  Settings.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI

class AppSettings: ObservableObject {
    @Published var numPerPage: Int = UserDefaults.standard.integer(forKey: "numPerPage")
    @Published var useRegion = UserDefaults.standard.bool(forKey: "useRegion")
    @Published var searchIgnoreFilters = UserDefaults.standard.bool(forKey: "searchIgnoreFilters")
    @Published var useGoogle = UserDefaults.standard.bool(forKey: "useGoogle")
}
