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
    @State private var showBottomSheet = true
    @State private var animateLoader = false
    private let clusterPixels = 30

    var body: some View {
        MapReader { mapProxy in
            GeometryReader { geoProxy in
                ZStack(alignment: .top) {
                    mainMap
                        .zIndex(1)
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

                    if viewModel.isLoading {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(.unisex))
                            .symbolEffect(.variableColor.iterative,
                                          options: .repeating.speed(0.5),
                                          value: animateLoader)
                            .padding(5)
                            .background {
                                Circle().foregroundStyle(.ultraThickMaterial)
                            }
                            .zIndex(2)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .onAppear {
                                withAnimation {
                                    animateLoader.toggle()
                                }
                            }
                    }
                }
                .onChange(of: viewModel.selectedCluster) { oldSelectedCluster, newSelectedCluster in
                    if let newSelectedCluster {
                        if let oldSelectedCluster,
                           newSelectedCluster.isSingle,
                           oldSelectedCluster.restrooms.contains(newSelectedCluster.restrooms) {
                            viewModel.previousCluster = oldSelectedCluster
                        } else {
                            viewModel.previousCluster = nil
                        }
                        viewModel.selectAnnotation(newSelectedCluster)
                        viewModel.adjustMapPosition(for: newSelectedCluster, with: mapProxy, in: geoProxy.size)
                    } else {
                        if let previousCluster = viewModel.previousCluster {
                            viewModel.selectAnnotation(previousCluster)
                            viewModel.adjustMapPosition(for: previousCluster, with: mapProxy, in: geoProxy.size)
                        }
                        if let distance = mapProxy.degreesFromPixels(clusterPixels) {
                            Task {
                                await viewModel.cluster(epsilon: distance)
                            }
                        }
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .sheet(isPresented: $showBottomSheet) {
            SheetView(
                selectedCluster: $viewModel.selectedCluster
            )
            .interactiveDismissDisabled()
            .presentationBackgroundInteraction(.enabled)
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: {
                if !$0 {
                    viewModel.error = nil
                    showBottomSheet = true
                }
            }
        ), actions: {
            Button("OK") { viewModel.error = nil }
        }, message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        })
    }
    
    @ViewBuilder
    var mainMap: some View {
        Map(position: $viewModel.cameraPosition,
            selection: $viewModel.selectedCluster) {
            ForEach(viewModel.clusters) { cluster in
                if cluster.size == 1, let restroom = cluster.restrooms.first {
                    Annotation(
                        restroom.name ?? "",
                        coordinate: restroom.coordinate,
                        anchor: .bottom ) {
                            RestroomAnnotation(
                                selection: $viewModel.selectedCluster,
                                restroom: restroom
                            )
                        }
                        .tag(cluster)
                } else {
                    Annotation(
                        "\(cluster.restrooms.first?.name ?? "")\n+\(cluster.restrooms.count - 1) more",
                        coordinate: cluster.center,
                        anchor: .center) {
                            ClusterAnnotation(
                                selection: $viewModel.selectedCluster,
                                cluster: cluster
                            )
                        }
                        .tag(cluster)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
