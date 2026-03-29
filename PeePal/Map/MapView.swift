//
//  MapView.swift
//  PeePal
//
//  Created by Thomas Patrick on 03/26/26.
//

import MapKit
import SwiftData
import SwiftUI

struct MapView: View {
    @State var viewModel: MapViewModel
    @State private var animateLoader = false
    
    var body: some View {
        MapReader { mapProxy in
            GeometryReader { geoProxy in
                ZStack(alignment: .top) {
                    mainMap
                        .zIndex(1)
                        .task {
                            viewModel.setInitialCameraPosition()
                            await viewModel.loadInitialRestrooms()
                        }
                        .onMapCameraChange { context in
                            if viewModel.regionHasChanged(context.region) {
                                viewModel.fetchRestrooms(region: context.region)
                            }
                        }
                        .onChange(of: viewModel.restrooms) { _, _ in
                            if let distance = mapProxy.degreesFromPixels(viewModel.clusterPixels) {
                                viewModel.cluster(epsilon: distance)
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
                        .padding(.top, 75) // No safe area
                        .onAppear {
                            withAnimation {
                                animateLoader = true
                            }
                        }
                        .onDisappear { animateLoader = false }
                    }
                }
                .onChange(of: viewModel.selectedCluster) { oldSelectedCluster, newSelectedCluster in
                    viewModel.handleClusterSelectionChange(
                        from: oldSelectedCluster,
                        to: newSelectedCluster,
                        mapProxy: mapProxy,
                        geoSize: geoProxy.size
                    )
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
