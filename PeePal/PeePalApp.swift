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
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: [RestroomEntity.self])
        }
    }
}
