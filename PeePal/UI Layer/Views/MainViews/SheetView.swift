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
    @State var locationManager = LocationManager()

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
                    VStack {
                        if selectedCluster.isSingle, let restroom = selectedCluster.restrooms.first {
                            RestroomView(
                                restroom: restroom,
                                locationManager: locationManager
                            )
                            .backgroundStyle(.regularMaterial)
                        } else {
                            List(selectedCluster.restrooms) { restroom in
                                Button {
                                    self.selectedCluster = RestroomCluster(restrooms: [restroom])
                                } label: {
                                    RestroomListView(
                                        restroom: restroom,
                                        locationManager: locationManager
                                    )
                                }
                            }
                            .listStyle(.plain)
                            .backgroundStyle(.regularMaterial)
                            .navigationTitle("\(selectedCluster.restrooms.count) Restrooms")
                            .navigationBarTitleDisplayMode(.large)
                        }
                    }
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(.ultraThickMaterial)
        .background(Color.accentColor.opacity(0.5))
        .animation(.easeInOut, value: selectedCluster)
        .presentationDetents([.low, .middle, .high], selection: $viewModel.currentDetent)
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled(upThrough: .middle))
        .onChange(of: selectedCluster) { _, newValue in
            if newValue != nil {
                viewModel.currentDetent = .middle
            } else {
                viewModel.currentDetent = .low
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    Color.accentColor.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SheetView(
                selectedCluster: .constant(nil))
        }
}

#Preview {
    Color.accentColor.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SheetView(
                selectedCluster: .constant(RestroomCluster(restrooms: [
                    exampleRestroom,
                    exampleRestroom,
                    exampleRestroom
                ])))
        }
}

#Preview {
    Color.accentColor.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            SheetView(
                selectedCluster: .constant(RestroomCluster(restrooms: [
                    exampleRestroom])))
        }
}
