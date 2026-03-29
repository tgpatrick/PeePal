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
    @State private var sheetCluster: RestroomCluster?

    var body: some View {
        ZStack {
            if let mapViewModel {
                MapView(viewModel: mapViewModel)
            } else {
                ProgressView()
                    .task {
                        mapViewModel = MapViewModel(modelContext: modelContext)
                    }
            }
        }
        .sheet(item: $sheetCluster) { cluster in
            ClusterSheetView(
                cluster: cluster,
                onSelectItem: mapViewModel?.selectAnnotation,
                onDismiss: mapViewModel?.clearSelectedAnnotation
            )
            .id(cluster.hashValue)
        }
        .onChange(of: mapViewModel?.selectedCluster) { _, newValue in
            // Copy of selected cluster ensures a new sheet for each cluster change
            sheetCluster = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if let newValue {
                    sheetCluster = newValue
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
