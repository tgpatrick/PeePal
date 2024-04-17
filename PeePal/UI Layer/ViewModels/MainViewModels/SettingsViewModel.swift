//
//  SettingsViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/14/20.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var picking = false // For changing the annotation view colors later
    let numbers = [40, 60, 80, 100, 120, 140, 160]
}
