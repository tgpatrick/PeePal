//
//  SearchResultsView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/15/20.
//

import SwiftData
import SwiftUI

struct SearchResultsView: View {
    @AppFilter(.accessible) private var accessFilter
    @AppFilter(.changingTable) private var tableFilter
    @AppFilter(.unisex) private var unisexFilter
    private var anyFilterEnabled: Bool { accessFilter || tableFilter || unisexFilter }
    private var filterCount: Int {
        (accessFilter ? 1 : 0) + (unisexFilter ? 1 : 0) + (tableFilter ? 1 : 0)
    }
    
    @State var viewModel: SearchViewModel
    @State private var currentDetent: PresentationDetent = .middle
    @State private var usingFilters: Bool = true
    
    let onItemTap: (any Listable) -> Void
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.anyResults, currentDetent != .low {
                    List {
                        Section(content: {
                            ForEach(viewModel.mapResults.prefix(1)) { result in
                                itemButton(result.item)
                            }
                        }, header: {
                            HStack {
                                Text("Map Results")
                                    .font(.title2)
                                Spacer()
                                NavigationLink("See All") {
                                    allResults(for: viewModel.mapResults, title: "Map")
                                }
                                .font(.subheadline)
                            }
                            .foregroundStyle(.primary)
                        })
                        
                        Section(content: {
                            if anyFilterEnabled {
                                Toggle(isOn: $usingFilters) {
                                    HStack {
                                        Text("Using your filter" + (filterCount > 1 ? "s:" : ":"))
                                        HStack(spacing: -15) {
                                            if unisexFilter {
                                                AvailabilityBadgeView(
                                                    for: .unisex,
                                                    isAvailable: usingFilters,
                                                    shouldInvert: false
                                                )
                                                .colorCircleShadow(.unisex.opacity(usingFilters ? 1 : 0.1))
                                                .scaleEffect(0.5)
                                            }
                                            if accessFilter {
                                                AvailabilityBadgeView(
                                                    for: .accessible,
                                                    isAvailable: usingFilters,
                                                    shouldInvert: false
                                                )
                                                .colorCircleShadow(.accessible.opacity(usingFilters ? 1 : 0.1))
                                                .scaleEffect(0.5)
                                            }
                                            if tableFilter {
                                                AvailabilityBadgeView(
                                                    for: .changingTable,
                                                    isAvailable: usingFilters,
                                                    shouldInvert: false
                                                )
                                                .colorCircleShadow(.changingTable.opacity(usingFilters ? 1 : 0.1))
                                                .scaleEffect(0.5)
                                            }
                                        }
                                        .padding(-15)
                                        Spacer()
                                    }
                                    .foregroundStyle(usingFilters ? Color.primary : Color.gray)
                                }
                            }
                            ForEach(viewModel.restroomResults.prefix(10)) { result in
                                itemButton(result.item)
                            }
                        }, header: {
                            VStack {
                                HStack {
                                    Text("Restroom Results")
                                        .font(.title2)
                                    if viewModel.loadingNetworkResults {
                                        ProgressView()
                                    }
                                    Spacer()
                                    if !viewModel.restroomResults.isEmpty {
                                        NavigationLink("See All") {
                                            allResults(for: viewModel.restroomResults, title: "Restroom")
                                        }
                                        .font(.subheadline)
                                    }
                                }
                                
                                
                            }
                            .foregroundStyle(.primary)
                        })
                    }
                    .listStyle(.plain)
                    .listSectionSpacing(0)
                } else if currentDetent != .low {
                    searchSuggestions
                }
            }
        }
        .searchable(
            text: $viewModel.searchText,
            isPresented: $viewModel.searching,
            placement: .toolbarPrincipal
        )
        .presentationDetents([.low, .middle, .high], selection: $currentDetent)
        .presentationBackgroundInteraction(.enabled(upThrough: .middle))
        .onChange(of: viewModel.searchText) {
            viewModel.search(
                useFilters: usingFilters,
                filters: .init(
                    accessible: accessFilter,
                    unisex: unisexFilter,
                    changingTable: tableFilter
                )
            )
        }
        .onChange(of: usingFilters) {
            viewModel.search(
                useFilters: usingFilters,
                filters: .init(
                    accessible: accessFilter,
                    unisex: unisexFilter,
                    changingTable: tableFilter
                )
            )
        }
        .onDisappear {
            if let onDismiss {
                onDismiss()
            }
            viewModel.clear()
        }
    }
    
    private var searchSuggestions: some View {
        VStack {
            Text("Search for")
                .font(.subheadline)
            Text("Restrooms")
                .font(.title2)
                .bold()
            Text("and")
                .font(.subheadline)
            Text(viewModel.currentSuggestion ?? "Places")
                .font(.title2)
                .bold()
                .id(viewModel.currentSuggestion)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity))
                )
        }
        .onAppear(perform: viewModel.startSuggestionAnimation)
        .onDisappear(perform: viewModel.stopSuggestionAnimation)
    }
    
    @ViewBuilder
    private func allResults(for results: [ListableItem], title: String = "") -> some View {
        List(results) { result in
            itemButton(result.item)
        }
        .listStyle(.plain)
        .navigationTitle("All \(title) Results")
    }
    
    private func itemButton(_ item: any Listable) -> some View {
        Button {
            currentDetent = .middle
            onItemTap(item)
        } label: {
            ListItemView(listItem: item)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    HomeView()
        .modelContainer(DataController.previewContainer)
}
#endif
