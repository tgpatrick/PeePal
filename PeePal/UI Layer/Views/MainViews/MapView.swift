//
//  MapView.swift
//  PeePal
//
//  Created by GitHub Copilot on 03/26/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    var viewModel: MapViewModel
    @State private var animateLoader = false
    private let clusterPixels = 30

    var body: some View {
        MapReader { mapProxy in
            GeometryReader { geoProxy in
                ZStack(alignment: .top) {
                    mainMap
                        .zIndex(1)
                        .onMapCameraChange { context in
                            viewModel.fetchRestrooms(region: context.region)

                            if viewModel.shouldClusterForRegion(context.region) {
                                Task {
                                    if let distance = mapProxy.degreesFromPixels(clusterPixels) {
                                        await viewModel.cluster(epsilon: distance)
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.restrooms) { _, _ in
                            if let distance = mapProxy.degreesFromPixels(clusterPixels) {
                                Task {
                                    await viewModel.cluster(epsilon: distance)
                                }
                            }
                        }

                    if viewModel.isLoading {
                        ZStack {
                            Image(systemName: "aqi.medium")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color(.unisex))
                                .symbolEffect(
                                    .variableColor.iterative,
                                    options: .repeating.speed(0.5),
                                    value: animateLoader)
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 45, height: 45)
                                .foregroundStyle(Color(.unisex))
                                .rotationEffect(Angle(
                                    degrees: animateLoader ? 360 : 0))
                                .animation(
                                    .easeInOut(duration: 1).repeatForever(autoreverses: false),
                                    value: animateLoader)
                        }
                        .padding(-4)
                        .background {
                            Circle().foregroundStyle(.ultraThickMaterial)
                        }
                        .shadow(radius: 5)
                        .zIndex(2)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            withAnimation {
                                animateLoader = true
                            }
                        }
                        .onDisappear { animateLoader = false }
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
        .onChange(of: viewModel.locationManager.location) { oldLocation, newLocation in
            if oldLocation == nil, let newLocation {
                viewModel.centerOn(newLocation)
            }
        }
    }

    @ViewBuilder
    var mainMap: some View {
        Map(position: $viewModel.cameraPosition,
            selection: $viewModel.selectedCluster) {
            UserAnnotation()
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

#Preview {
    MapView(viewModel: MapViewModel(modelContext: ModelContext(ModelContainer(for: RestroomEntity.self, inMemory: true))))
}
