//
//  SearchResultsView.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/29/26.
//

import SwiftData
import SwiftUI

struct SearchResultsView: View {
    @State var viewModel: SearchViewModel
    @State private var currentDetent: PresentationDetent = .middle
    
    let onItemTap: (any Listable) -> Void
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            if viewModel.anyResults, currentDetent != .low {
                List {
                    Section(content: {
                        ForEach(viewModel.mapResults.prefix(3)) { result in
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
                        ForEach(viewModel.restroomResults.prefix(3)) { result in
                            itemButton(result.item)
                        }
                    }, header: {
                        HStack {
                            Text("Restroom Results")
                                .font(.title2)
                            Spacer()
                            NavigationLink("See All") {
                                allResults(for: viewModel.restroomResults, title: "Restroom")
                            }
                            .font(.subheadline)
                        }
                        .foregroundStyle(.primary)
                    })
                }
                .listStyle(.plain)
            } else if currentDetent != .low {
                HStack {
                    Text("Search for:")
                }
            } else {
                List {} // Otherwise the search bar disappears and everything crashes
            }
        }
        .searchable(
            text: $viewModel.searchText,
            isPresented: $viewModel.searching,
            placement: .toolbarPrincipal
        )
        .presentationDetents([.low, .middle, .high], selection: $currentDetent)
        .presentationBackgroundInteraction(.enabled(upThrough: .middle))
        .onChange(of: viewModel.searchText, viewModel.search)
        .onDisappear {
            if let onDismiss {
                onDismiss()
            }
            viewModel.clear()
        }
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

#Preview {
    HomeView()
        .modelContainer(DataController.previewContainer)
}
