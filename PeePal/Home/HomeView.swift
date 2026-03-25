//
//  HomeView.swift
//  PeePal
//
//  Created by Thomas Patrick on 1/25/26.
//

import MapKit
import SwiftUI

struct HomeView: View {
    var body: some View {
        MapReader { mapProxy in
            Map()
        }
        .task {
            do {
                let restrooms = try await RestroomService.shared.fetchAllRestrooms()
                let jsonData = try JSONEncoder().encode(restrooms)
                let json = String(data: jsonData, encoding: .utf8) ?? "<invalid json>"
                print("RestroomService fetchAllRestrooms succeeded (\(restrooms.count)) restrooms")
                print(json)
            } catch {
                print("RestroomService fetchAllRestrooms failed: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
}
