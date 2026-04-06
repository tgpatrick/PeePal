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
    @State private var showSearch: Bool = false
    
    let sheetDismissTime = 0.25

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
                        showSearch = true
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Settings", systemImage: "gearshape") {
                        
                    }
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            if let searchViewModel, let mapViewModel {
                SearchResultsView(
                    viewModel: searchViewModel,
                    onItemTap: { item in
                        showSearch = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + sheetDismissTime * 2) {
                            mapViewModel.focusOn(item)
                        }
                    },
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
            runAfterSheetDismiss {
                if let newValue, newValue != mapResultCluster {
                    sheetCluster = newValue
                }
            }
        }
        .onChange(of: showSearch) { _, newValue in
            runAfterSheetDismiss {
                searchViewModel?.searching = newValue
            }
        }
        .onChange(of: searchViewModel?.searching) { _, newValue in
            if let newValue, !newValue {
                showSearch = false
            }
        }
        .onChange(of: mapViewModel?.selectedMapItem) { _, newValue in
            if newValue != nil {
                mapViewModel?.selectedCluster = mapResultCluster
            }
        }
    }
    
    func runAfterSheetDismiss(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + sheetDismissTime) {
            completion()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(DataController.previewContainer)
}
