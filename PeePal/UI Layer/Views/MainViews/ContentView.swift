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

    var body: some View {
        ZStack {
            MapReader { mapProxy in
                Map(position: $viewModel.cameraPosition) {
                    ForEach(viewModel.clusters) { cluster in
                        if cluster.size == 1, let restroom = cluster.restrooms.first {
                            Marker(restroom.name ?? "Restroom",
                                   systemImage: "toilet.fill",
                                   coordinate: restroom.coordinate)
                        } else {
                            Marker("",
                                   systemImage: "\(cluster.size).circle",
                                   coordinate: cluster.center)
                            .tint(Color.green)
                        }
                    }
                }
                .onMapCameraChange { context in
                    Task {
                        if let distance = mapProxy.degrees(fromPixels: 30) {
                            await viewModel.cluster(epsilon: distance)
                        }
                        viewModel.fetchRestrooms(region: context.region)
                    }
                }
                .onChange(of: viewModel.restrooms, { _, _ in
                    if let distance = mapProxy.degrees(fromPixels: 30) {
                        Task {
                            await viewModel.cluster(epsilon: distance)
                        }
                    }
                })
            }
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
