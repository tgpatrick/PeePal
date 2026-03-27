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
    @State private var mapViewModel: MapViewModel?

    var body: some View {
        if let mapViewModel {
            MapView(viewModel: mapViewModel)
        } else {
            ProgressView()
                .task {
                    mapViewModel = MapViewModel(modelContext: modelContext)
                    do {
                        try await mapViewModel?.restroomManager.initializeFromBundleIfNeeded()
                        await mapViewModel?.loadInitialRestrooms()
                    } catch {
                        print("Failed to initialize from bundle: \(error)")
                    }
                }
        }
    }
}

#Preview {
    HomeView()
}
