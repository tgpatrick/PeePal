//
//  PeePalApp.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/10/20.
//

import SwiftUI
import SwiftData

@main
struct PeePalApp: App {
    @AppStorage(Setting.colorScheme.rawValue) private var appearance: Appearance = .system
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(appearance.colorScheme)
                .modelContainer(for: [RestroomEntity.self])
        }
    }
}
