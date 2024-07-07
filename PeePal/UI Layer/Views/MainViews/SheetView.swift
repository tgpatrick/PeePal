//
//  SheetView.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/5/24.
//

import SwiftUI

struct SheetView: View {
    @State var viewModel: SheetViewModel = SheetViewModel()
    @Binding var selectedCluster: RestroomCluster?

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $viewModel.searchField)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(
                            Color.secondary.opacity(0.25)
                        )
                )
                .padding()
                Spacer()
            }
            if let selectedCluster {
                NavigationStack {
                    if selectedCluster.isSingle, let restroom = selectedCluster.restrooms.first {
                        ScrollView {
                            RestroomListView(restroom: restroom)
                                .padding(.horizontal)
                        }
                        .navigationTitle(restroom.name ?? "")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            Button {
                                _selectedCluster.wrappedValue = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(8)
                                    .foregroundStyle(.regularMaterial)
                                    .frame(height: 30)
                                    .background(
                                        Circle()
                                            .fill(Color.secondary.opacity(0.75))
                                    )
                                    .fontWeight(.heavy)
                            }
                        }
                    } else {
                        List(selectedCluster.restrooms) { restroom in
                            Button {
                                self.selectedCluster = RestroomCluster(restrooms: [restroom])
                            } label: {
                                RestroomListView(restroom: restroom)
                            }
                        }
                        .listStyle(.plain)
                        .navigationTitle("\(selectedCluster.restrooms.count) Restrooms")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            Button {
                                _selectedCluster.wrappedValue = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(8)
                                    .foregroundStyle(.regularMaterial)
                                    .frame(height: 30)
                                    .background(
                                        Circle()
                                            .fill(Color.secondary.opacity(0.75))
                                    )
                                    .fontWeight(.heavy)
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(.ultraThickMaterial)
        .background(Color.accentColor.opacity(0.5))
        .animation(.easeInOut, value: selectedCluster)
        .presentationDetents([.low, .middle, .high], selection: $viewModel.currentDetent)
        .onChange(of: selectedCluster) { _, newValue in
            if newValue != nil {
                viewModel.currentDetent = .middle
            } else {
                viewModel.currentDetent = .low
            }
        }
    }
}

#Preview {
    Color.indigo
        .sheet(isPresented: .constant(true)) {
            SheetView(
                selectedCluster: .constant(RestroomCluster(restrooms: [exampleRestroom])))
            .interactiveDismissDisabled()
        }
}

#Preview {
    Color.indigo.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SheetView(
                selectedCluster: .constant(nil))
            .interactiveDismissDisabled()
        }
}
