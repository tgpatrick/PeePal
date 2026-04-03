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
            if viewModel.anyResults {
                List {
                    Section(content: {
                        ForEach(viewModel.mapResults.prefix(3)) { result in
                            Button(action: {
                                currentDetent = .middle
                                onItemTap(result.item)
                            }) {
                                ListItemView(listItem: result.item)
                                    .padding(.horizontal, 5)
                            }
                        }
                        .buttonStyle(.plain)
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
                            Button(action: {
                                currentDetent = .middle
                                onItemTap(result.item)
                            }) {
                                ListItemView(listItem: result.item)
                                    .padding(.horizontal, 5)
                            }
                        }
                        .buttonStyle(.plain)
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
            } else {
                HStack {
                    Text("Search for:")
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
            ListItemView(listItem: result.item)
        }
        .listStyle(.plain)
        .navigationTitle("All \(title) Results")
    }
}

#Preview {
    HomeView()
        .modelContainer(DataController.previewContainer)
}
