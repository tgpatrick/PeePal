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
    
    @AppFilter(.accessible) private var accessFilter
    @AppFilter(.changingTable) private var tableFilter
    @AppFilter(.unisex) private var unisexFilter
    
    @AppSetting(.liquidGlassDisabled) private var isLiquidGlassDisabled: Bool
    @AppSetting(.offlineMode) private var isOfflineModeEnabled: Bool
    
    @Namespace private var homeNamespace
    
    @State private var mapViewModel: MapViewModel?
    @State private var searchViewModel: SearchViewModel?
    @State private var sheetCluster: RestroomCluster?
    @State private var showSearch: Bool = false
    @State private var showFilter: Bool = false
    @State private var showSettings: Bool = false
    
    private var filterCount: Int {
        (accessFilter ? 1 : 0) + (unisexFilter ? 1 : 0) + (tableFilter ? 1 : 0)
    }
    
    let sheetDismissTime = 0.25
    var disableBottomControls: Bool {
        showSearch ||
        sheetCluster != nil
    }
    
    var body: some View {
        if #available(iOS 26.0, *), !isLiquidGlassDisabled {
            GeometryReader { geo in
                container(width: geo.size.width, withModifiers(content))
            }
        } else {
            compatibilityContainter(withModifiers(content))
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let mapViewModel {
            MapView(viewModel: mapViewModel)
                .ignoresSafeArea(.keyboard)
            if mapViewModel.isLoading {
                LoadingSpinner()
            } else if mapViewModel.error != nil {
                Button("Try again", systemImage: .errorIcon, role: .destructive) {
                    mapViewModel.fetchRestrooms(fetchFromNetwork: true)
                }
                .modifier(GlassyOrProminentButton())
            } else if isOfflineModeEnabled && mapViewModel.showRefresh {
                RefreshButton {
                    mapViewModel.fetchRestrooms(fetchFromNetwork: true)
                }
            }
        } else {
            ProgressView()
                .onAppear {
                    mapViewModel = MapViewModel(modelContext: modelContext)
                    searchViewModel = SearchViewModel(modelContext: modelContext)
                }
        }
    }
    
    private func filterButtonLabel<Content: View>(_ content: Content) -> some View {
        ZStack {
            content
            if !showFilter && filterCount > 0 {
                Text("\(filterCount)")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundStyle(.black)
                    .background {
                        Circle()
                            .fill(.accent)
                            .frame(width: 20, height: 20)
                    }
                    .offset(x: 15, y: -10)
                    .transition(.scale)
            }
        }
    }
    
    @available(iOS 26.0, *)
    private func container<Content: View>(width: CGFloat, _ content: Content) -> some View {
        ZStack(alignment: .top) {
            content
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showFilter = true
                } label: {
                    filterButtonLabel(Image(systemName: .filterIcon))
                }
                .disabled(disableBottomControls)
                .matchedTransitionSource(id: "filter", in: homeNamespace)
            }
            
            ToolbarSpacer(.fixed, placement: .bottomBar)
            ToolbarItem(id: "search", placement: .bottomBar) {
                Button {
                    showSearch = true
                } label: {
                    HStack {
                        Image(systemName: .searchIcon)
                            .foregroundStyle(.secondary)
                        Text("Search")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(minWidth: width * 0.5)
                .disabled(disableBottomControls)
                .matchedTransitionSource(id: "search", in: homeNamespace)
            }
            ToolbarSpacer(.fixed, placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                Button("settings", systemImage: .settingsIcon) {
                    showSettings = true
                    showFilter = false // Fixes a weird edge case
                }
                .disabled(disableBottomControls)
                .matchedTransitionSource(id: "settings", in: homeNamespace)
            }
            ToolbarSpacer(.flexible, placement: .bottomBar)
        }
    }
    
    private func compatibilityContainter<Content: View>(_ content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Button {
                        showFilter = true
                    } label: {
                        filterButtonLabel(
                            Image(systemName: .filterIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.heavy)
                                .foregroundStyle(.buttonYellow)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(.regularMaterial)
                                        .strokeBorder(.buttonYellow, lineWidth: 3)
                                )
                        )
                    }
                    .compositingGroup()
                    .transitionSourceIfAvailable(id: "filter", in: homeNamespace)
                    
                    Spacer()
                    Button {
                        showSearch = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: .searchIcon)
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
                    .transitionSourceIfAvailable(id: "search", in: homeNamespace)
                    
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: .settingsIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.heavy)
                            .foregroundStyle(.buttonYellow)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(.regularMaterial)
                                    .strokeBorder(.buttonYellow, lineWidth: 3)
                            )
                    }
                    .compositingGroup()
                }
                .frame(height: 40)
                .shadow(radius: 5)
                .padding(.horizontal)
                .padding(.horizontal)
            }
            .disabled(disableBottomControls)
        }
    }
    
    private func withModifiers<Content: View>(_ content: Content) -> some View {
        content
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
                        onDismiss: {}
                    )
                    .materialPresentationBackground(isLiquidGlassDisabled)
                    .interactiveDismissDisabled()
                    .zoomTransitionIfAvailable(sourceID: "search", in: homeNamespace, enabled: !isLiquidGlassDisabled)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .materialPresentationBackground(isLiquidGlassDisabled)
                    .zoomTransitionIfAvailable(sourceID: "settings", in: homeNamespace, enabled: !isLiquidGlassDisabled)
            }
            .sheet(item: $sheetCluster) { cluster in
                ClusterSheetView(
                    cluster: cluster,
                    onSelectItem: mapViewModel?.selectAnnotation,
                    onDismiss: mapViewModel?.clearSelectedAnnotation
                )
                .materialPresentationBackground(isLiquidGlassDisabled)
                .id(cluster.hashValue)
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showFilter) {
                FilterView()
                    .materialPresentationBackground(isLiquidGlassDisabled)
                    .presentationDetents([.lowHalf])
                    .zoomTransitionIfAvailable(sourceID: "filter", in: homeNamespace, enabled: !isLiquidGlassDisabled)
            }
            .onChange(of: mapViewModel?.selectedCluster) { _, newValue in
                // Copy of selected cluster ensures a new sheet for each cluster change
                sheetCluster = nil
                showSearch = false
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
    
    private func runAfterSheetDismiss(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + sheetDismissTime) {
            completion()
        }
    }
}

#if DEBUG
#Preview {
    HomeView()
        .modelContainer(DataController.previewContainer)
}
#endif
