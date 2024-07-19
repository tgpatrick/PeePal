//
//  ContentViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI
import CoreLocation
import Observation
import MapKit
import DBSCAN
import simd
import OSLog

@Observable
class ContentViewModel {
    var clusters: [RestroomCluster] = []
    var restrooms: Set<Restroom> = []
    var selectedCluster: RestroomCluster?
    var previousCluster: RestroomCluster?
    var isLoading = false
    var error: NetworkError?
    var cameraPosition = MapCameraPosition.automatic
    var searchField: String = ""

    private var fetchTask: Task<Void, Error>? = nil
    private let logger = Logger()
    let locationManager = LocationManager.shared

    func centerOn(_ location: CLLocation) {
        cameraPosition = .region(MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    func fetchRestrooms(region: MKCoordinateRegion? = nil) {
        fetchTask?.cancel()

        fetchTask = Task.detached { [self] in
            await Task.yield()
            guard let fetchRegion = region ?? cameraPosition.region else { return }
            do {
                var page = 1
                while page < 3 && !Task.isCancelled {
                    if !isLoading {
                        await setLoading(true)
                    }
                    let newRestrooms = try await RestroomService.fetchRestrooms(near: fetchRegion.center, page: page)
                    if !newRestrooms.isEmpty {
                        restrooms.formUnion(newRestrooms)
                        page += 1
                    } else {
                        break
                    }
                }
                await setLoading(false)
            } catch let error as NetworkError {
                if case let .networkError(nestedError) = error, nestedError.localizedDescription == "cancelled" {
                    logger.info("Network cancellation successful")
                } else {
                    self.error = error
                    await setLoading(false)
                }
            } catch {
                self.error = .unknownError
                await setLoading(false)
            }
        }
    }
    
    @MainActor
    private func setLoading(_ value: Bool) {
        withAnimation {
            isLoading = value
        }
    }

    func cluster(epsilon: Double) async {
        guard !restrooms.isEmpty else { return }

        let dbScanTask = Task { () -> [RestroomCluster] in

            // Convert restrooms to points for DBSCAN
            let points: [SIMD3<Double>] = restrooms.map {
                SIMD3<Double>(x: $0.coordinate.latitude, y: $0.coordinate.longitude, z: 0.0)
            }

            // Run DBSCAN on the points
            let dbscan = DBSCAN(points)
            let (clusters, _) = dbscan(epsilon: epsilon, minimumNumberOfPoints: 1, distanceFunction: simd.distance)

            // Create RestroomCluster objects from clusters
            return clusters.compactMap { cluster -> RestroomCluster? in
                guard !cluster.isEmpty else { return nil }
                let restroomsInCluster = restrooms.filter { point in
                    cluster.contains(where: { $0.x == point.coordinate.latitude && $0.y == point.coordinate.longitude })
                }
                return RestroomCluster(restrooms: Array(restroomsInCluster))
            }
        }
        
        var clusters = await dbScanTask.value
        if let selectedCluster, !clusters.contains(selectedCluster) {
            clusters.append(selectedCluster)
        }
        let newClusters = clusters
        await MainActor.run {
            self.clusters = newClusters
        }
    }

    func selectAnnotation(_ cluster: RestroomCluster) {
        if cluster.size == 1 {
            guard let restroom = cluster.restrooms.first else { return }
            clusters.removeAll(where: { cluster in
                cluster.restrooms.contains(where: { $0.id == restroom.id })
            })
        }
        clusters.append(cluster)
        if selectedCluster != cluster {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.selectedCluster = cluster
            }
        }
    }

    func adjustMapPosition(for cluster: RestroomCluster, with mapProxy: MapProxy, in size: CGSize) {
        guard let clusterPoint = mapProxy.convert(cluster.center, to: .global),
              let topLeft = mapProxy.convert(CGPoint(x: 0, y: 0), from: .local),
              let bottomRight = mapProxy.convert(CGPoint(x: size.width, y: size.height), from: .local)
        else { return }
        var mapRect = MKMapRect(topLeft: topLeft, bottomRight: bottomRight)
        var originPoint = CGPoint(x: 0, y: 0)
        
        let topPadding = size.height * 0.1
        let bottomPadding = size.height * 0.4
        let sidePadding = size.width * 0.1

        if clusterPoint.y > size.height - bottomPadding {
            let pixelsToMove = clusterPoint.y - (size.height - bottomPadding)
            originPoint.y += pixelsToMove
        } else if clusterPoint.y < topPadding {
            originPoint.y = -topPadding
        }

        if clusterPoint.x > size.width - sidePadding {
            let pixelsToMove = clusterPoint.x - (size.width - sidePadding)
            originPoint.x += pixelsToMove
        } else if clusterPoint.x < sidePadding {
            originPoint.x = -sidePadding
        }

        guard let newOriginCoords = mapProxy.convert(originPoint, from: .local) else { return }
        let newOrigin = MKMapPoint(newOriginCoords)
        if mapRect.origin.y != newOrigin.y || mapRect.origin.x != newOrigin.x {
            mapRect.origin = newOrigin
            withAnimation {
                cameraPosition = .rect(mapRect)
            }
        }
    }
}

extension MKMapRect {
    init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
        let topLeftPoint = MKMapPoint(topLeft)
        let bottomRightPoint = MKMapPoint(bottomRight)

        let origin = MKMapPoint(x: min(topLeftPoint.x, bottomRightPoint.x),
                                y: min(topLeftPoint.y, bottomRightPoint.y))

        let width = abs(topLeftPoint.x - bottomRightPoint.x)
        let height = abs(topLeftPoint.y - bottomRightPoint.y)
        let size = MKMapSize(width: width, height: height)
        self.init(origin: origin, size: size)
    }
}

extension MapProxy {
    func degreesFromPixels(_ pixels: Int) -> Double? {
        guard let c1 = convert(CGPoint.zero, from: .global) else { return nil }
        let p2 = CGPoint(x: Double(pixels), y: 0.0)
        guard let c2 = convert(p2, from: .global) else { return nil }
        return abs(c1.longitude - c2.longitude)
    }
}
