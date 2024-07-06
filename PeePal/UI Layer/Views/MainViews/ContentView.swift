//
//  ContentView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/10/20.
//
import SwiftUI
import MapKit

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    private let clusterPixels = 30
    private let minimumSheetHeight = 75.0
    
    var body: some View {
        ZStack {
            MapReader { mapProxy in
                Map(position: $viewModel.cameraPosition,
                    selection: $viewModel.selectedCluster) {
                    ForEach(viewModel.clusters) { cluster in
                        if cluster.size == 1, let restroom = cluster.restrooms.first {
                            Annotation(
                                restroom.name ?? "",
                                coordinate: restroom.coordinate,
                                anchor: .bottom) {
                                    RestroomAnnotation(restroom: restroom)
                                }
                                .tag(cluster)
                        } else {
                            Annotation(
                                "",
                                coordinate: cluster.center,
                                anchor: .center) {
                                    ClusterAnnotation(cluster: cluster)
                                }
                                .tag(cluster)
                        }
                    }
                }
                    .padding(.bottom, minimumSheetHeight / 2)
                    .onMapCameraChange { context in
                        Task {
                            if let distance = mapProxy.degreesFromPixels(clusterPixels) {
                                await viewModel.cluster(epsilon: distance)
                            }
                            viewModel.fetchRestrooms(region: context.region)
                        }
                    }
                    .onChange(of: viewModel.restrooms, { _, _ in
                        if let distance = mapProxy.degreesFromPixels(clusterPixels) {
                            Task {
                                await viewModel.cluster(epsilon: distance)
                            }
                        }
                    })
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
        }
        .animation(.bouncy, value: viewModel.selectedCluster)
        .sheet(isPresented: .constant(true)) {
            SheetView(
                searchField: $viewModel.searchField,
                selectedCluster: $viewModel.selectedCluster
            )
            .presentationDetents([.height(minimumSheetHeight), .fraction(0.4), .fraction(0.99)])
            .interactiveDismissDisabled()
            .presentationBackgroundInteraction(.enabled)
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        ), actions: {
            Button("OK") { viewModel.error = nil }
        }, message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
