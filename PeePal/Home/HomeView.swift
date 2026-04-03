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
    @State private var searchViewModel: SearchViewModel?
    @State private var sheetCluster: RestroomCluster?

    var body: some View {
            ZStack(alignment: .top) {
                if let mapViewModel {
                    MapView(viewModel: mapViewModel)
                        .ignoresSafeArea(.keyboard)
                    if mapViewModel.isLoading {
                        LoadingSpinner()
                    }
                } else {
                    ProgressView()
                        .onAppear {
                            mapViewModel = MapViewModel(modelContext: modelContext)
                            searchViewModel = SearchViewModel(modelContext: modelContext)
                        }
                }
            }
        .toolbar {
            if !(searchViewModel?.searching ?? false) {
                ToolbarItem(id: "search", placement: .bottomBar) {
                    Button("Search", systemImage: "magnifyingglass") {
                        searchViewModel?.searching = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Settings", systemImage: "gearshape") {
                        
                    }
                }
            }
        }
        .sheet(isPresented: .init(get: {
            searchViewModel?.searching ?? false
        }, set: { newValue in
            searchViewModel?.searching = newValue
        })) {
            if let searchViewModel, let mapViewModel {
                SearchResultsView(
                    viewModel: searchViewModel,
                    onItemTap: mapViewModel.focusOn,
                    onDismiss: {
                        mapViewModel.selectedMapItem = nil
                    })
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
        .modelContainer(DataController.previewContainer)
}
