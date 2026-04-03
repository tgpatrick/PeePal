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
                if cluster.isSingle, let restroom = cluster.restrooms.first {
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
            if let selectedMapItem = viewModel.selectedMapItem, viewModel.selectedCluster == nil {
                Annotation(
                    selectedMapItem.fullName,
                    coordinate: selectedMapItem.placemark.coordinate,
                    anchor: .center) {
                        MapItemAnnotationView(mapItem: selectedMapItem)
                    }
            }
        }
    }
}
