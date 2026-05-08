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
    @AppSetting(.colorScheme) private var appearance: Appearance
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(appearance.scheme)
                .modelContainer(for: [RestroomEntity.self])
        }
    }
}
