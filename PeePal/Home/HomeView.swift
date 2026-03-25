//
//  HomeView.swift
//  PeePal
//
//  Created by Thomas Patrick on 1/25/26.
//

import MapKit
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MapReader { mapProxy in
            Map()
        }
        .task {
            let restroomManager = RestroomManager(modelContext: modelContext)
            do {
                print("Starting bundle initialization check...")
                try await restroomManager.initializeFromBundleIfNeeded()
                print("Bundle initialization check complete.")

                print("Fetching all restrooms...")
                let restrooms = try await restroomManager.fetchAllRestrooms()
                let jsonData = try JSONEncoder().encode(restrooms)
                let json = String(data: jsonData, encoding: .utf8) ?? "<invalid json>"
                print("RestroomManager fetchAllRestrooms succeeded (\(restrooms.count)) restrooms")
                print(json)
            } catch {
                print("RestroomManager operation failed: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
}
