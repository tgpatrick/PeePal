//
//  SettingsViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/14/20.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var picking = false // For changing the annotation view colors later
    let numbers = [10, 20, 30, 40, 50, 60, 70, 80, 90]
}
