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
    var showBottomControls: Bool {
        !(searchViewModel?.searching ?? false) && sheetCluster == nil
    }
    
    var body: some View {
        GeometryReader { geo in
            if #available(iOS 26.0, *) {
                container(width: geo.size.width, content)
            } else {
                compatibilityContainter(content)
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
                    onDismiss: {})
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
                if let newValue, newValue != mapItemCluster {
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
    }
    
    @ViewBuilder
    var content: some View {
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
    
    @available(iOS 26.0, *)
    @ViewBuilder
    func container<Content: View>(width: CGFloat, _ content: Content) -> some View {
        ZStack(alignment: .top) {
            content
        }
        .toolbar {
            if showBottomControls {
                ToolbarItem(id: "filter", placement: .bottomBar) {
                    Button("filter", systemImage: "line.3.horizontal.decrease") {

                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(id: "search", placement: .bottomBar) {
                    Button {
                        showSearch = true
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            Text("Search")
                                .foregroundStyle(.secondary)
                        }
                        .frame(minWidth: width * 0.575)
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("settings", systemImage: "gearshape") {
                        
                    }
                }
            } else {
                ToolbarSpacer(.fixed, placement: .bottomBar)
            }
        }
    }
    
    @ViewBuilder
    func compatibilityContainter<Content: View>(_ content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if showBottomControls {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.heavy)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(.thickMaterial)
                                        .strokeBorder(.accent, lineWidth: 3)
                                )
                        }
                        .compositingGroup()
                        Spacer()
                        Button {
                            showSearch = true
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                Text("Search")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                Capsule().foregroundStyle(.ultraThinMaterial)
                            )
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.heavy)
                                .padding(5)
                                .background(
                                    Circle()
                                        .fill(.thickMaterial)
                                        .strokeBorder(.accent, lineWidth: 3)
                                )
                        }
                        .compositingGroup()
                    }
                    .frame(height: 40)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
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
