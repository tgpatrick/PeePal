//
//  MapViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 03/26/26.
//

import SwiftUI
import CoreLocation
import Observation
import MapKit
import DBSCAN
import simd
import OSLog
import SwiftData

@Observable
class MapViewModel {
    var clusters: [RestroomCluster] = []
    var restrooms: Set<Restroom> = []
    var selectedCluster: RestroomCluster?
    var previousCluster: RestroomCluster?
    var isLoading = false
    var error: NetworkError_old?
    var cameraPosition = MapCameraPosition.automatic

    private var fetchTask: Task<Void, Error>? = nil
    private var clusteringTask: Task<Void, Never>? = nil
    private var clusteringWorkItem: DispatchWorkItem? = nil
    private let logger = Logger()
    let locationManager = LocationManager.shared
    let restroomManager: RestroomManager
    
    private var dbscan: DBSCAN<SIMD3<Double>> {
        let points: [SIMD3<Double>] = restrooms.map {
            SIMD3<Double>(x: $0.coordinate.latitude, y: $0.coordinate.longitude, z: 0.0)
        }
        
        return DBSCAN(points)
    }
    
    private var pointLookup: [SIMD3<Double>: Restroom] {
        var pointLookup: [SIMD3<Double>: Restroom] = [:]
        for restroom in self.restrooms {
            let point = SIMD3<Double>(x: restroom.coordinate.latitude, y: restroom.coordinate.longitude, z: 0.0)
            pointLookup[point] = restroom
        }
        return pointLookup
    }

    init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }
    
    deinit {
        fetchTask?.cancel()
        clusteringTask?.cancel()
        clusteringWorkItem?.cancel()
    }

    func centerOn(_ location: CLLocation) {
        cameraPosition = .region(MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    func loadInitialRestrooms() async {
        do {
            isLoading = true
            let allRestrooms = try await restroomManager.fetchAllRestrooms()
            restrooms.formUnion(allRestrooms)
            logger.info("Loaded \(allRestrooms.count) initial restrooms")
        } catch {
            logger.error("Failed to load initial restrooms: \(error)")
            self.error = .unknownError
        }
        isLoading = false
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
                    let newRestrooms = try await restroomManager.fetchRestrooms(near: fetchRegion.center, page: page)
                    if !newRestrooms.isEmpty {
                        restrooms.formUnion(newRestrooms)
                        page += 1
                    } else {
                        break
                    }
                }
                await setLoading(false)
            } catch let error as NetworkError_old {
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

    func cluster(epsilon: Double) {
        clusteringWorkItem?.cancel()
        clusteringTask?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.clusteringTask = Task {
                await self.performClustering(epsilon: epsilon)
            }
        }

        clusteringWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: workItem)
    }

    private func performClustering(epsilon: Double) async {
        guard !restrooms.isEmpty else { return }

        let clusters = await Task.detached { [pointLookup = self.pointLookup, dbscan = self.dbscan] in
            let (clusterPoints, _) = dbscan(epsilon: epsilon, minimumNumberOfPoints: 1, distanceFunction: simd.distance)

            return clusterPoints.compactMap { cluster -> RestroomCluster? in
                guard !cluster.isEmpty else { return nil }

                let restroomsInCluster = cluster.compactMap { pointLookup[$0] }
                return restroomsInCluster.isEmpty ? nil : RestroomCluster(restrooms: restroomsInCluster)
            }
        }.value

        var clustersWithSelection = clusters
        if let selectedCluster, !clustersWithSelection.contains(selectedCluster) {
            clustersWithSelection.append(selectedCluster)
        }

        let concurrencySafeClusters = clustersWithSelection
        await MainActor.run {
            self.clusters = concurrencySafeClusters
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
