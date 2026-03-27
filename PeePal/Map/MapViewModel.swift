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

@MainActor
@Observable
class MapViewModel {
    var clusters: [RestroomCluster] = []
    var restrooms: Set<Restroom> = []
    var selectedCluster: RestroomCluster?
    var previousCluster: RestroomCluster?
    var isLoading = false
    var error: NetworkError?
    var cameraPosition = MapCameraPosition.automatic

    private var fetchTask: Task<Void, Error>? = nil
    private var clusteringTask: Task<Void, Never>? = nil
    private let logger = Logger()
    let locationManager = LocationManager.shared
    let restroomManager: RestroomManager
    let clusterPixels = 30

    private var cachedPoints: [SIMD3<Double>]? = nil
    private var cachedPointLookup: [SIMD3<Double>: Restroom]? = nil
    private var lastRestroomCount: Int = 0
    private var lastZoomDeltaSum: Double?

    init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }

    func shouldClusterForRegion(_ region: MKCoordinateRegion) -> Bool {
        let currentZoomSum = region.span.latitudeDelta + region.span.longitudeDelta

        if let previousZoom = lastZoomDeltaSum {
            let threshold = 0.0001
            if abs(currentZoomSum - previousZoom) < threshold {
                return false
            }
        }

        lastZoomDeltaSum = currentZoomSum
        return true
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
            // If a known region exists, fetch restrooms in that region to limit data
            if let region = cameraPosition.region {
                let regionRestrooms = try await restroomManager.fetchRestrooms(in: region)
                restrooms.formUnion(regionRestrooms)
                logger.info("Loaded \(regionRestrooms.count) restrooms in initial region")
            } else {
                // Fallback to loading all restrooms if no region is set
                let allRestrooms = try await restroomManager.fetchAllRestrooms()
                restrooms.formUnion(allRestrooms)
                logger.info("Loaded \(allRestrooms.count) initial restrooms")
            }
        } catch {
            logger.error("Failed to load initial restrooms: \(error)")
            self.error = .unknownError
        }
        isLoading = false
    }

    func fetchRestrooms(region: MKCoordinateRegion? = nil) {
        fetchTask?.cancel()

        let fetchRegion = region ?? cameraPosition.region

        fetchTask = Task.detached { [self] in
            await Task.yield()
            guard let region = fetchRegion else {
                // No region available, fallback to network fetch near camera center with paging
                await MainActor.run { self.setLoading(true) }
                do {
                    var page = 1
                    while page < 3 && !Task.isCancelled {
                        let newRestrooms = try await restroomManager.fetchRestrooms(near: self.cameraPosition.region?.center ?? CLLocationCoordinate2D(), page: page)
                        if !newRestrooms.isEmpty {
                            await MainActor.run { self.restrooms.formUnion(newRestrooms) }
                            page += 1
                        } else {
                            break
                        }
                    }
                    await MainActor.run { self.setLoading(false) }
                } catch let error as NetworkError {
                    if case let .networkError(nestedError) = error, nestedError.localizedDescription == "cancelled" {
                        logger.info("Network cancellation successful")
                    } else {
                        await MainActor.run {
                            self.error = error
                            self.setLoading(false)
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.error = .unknownError
                        self.setLoading(false)
                    }
                }
                return
            }

            // Region-based fetch, prefer fetching restrooms in the given region (likely local or more efficient)
            await MainActor.run { self.setLoading(true) }
            do {
                // Attempt to fetch restrooms in the region
                let newRestrooms = try await restroomManager.fetchRestrooms(in: region)
                if !newRestrooms.isEmpty {
                    await MainActor.run { self.restrooms = Set<Restroom>(newRestrooms) }
                } else {
                    // If no restrooms found or empty, fallback to network paging fetch near region center
                    var page = 1
                    while page < 3 && !Task.isCancelled {
                        let fallbackRestrooms = try await restroomManager.fetchRestrooms(near: region.center, page: page)
                        if !fallbackRestrooms.isEmpty {
                            await MainActor.run { self.restrooms.formUnion(fallbackRestrooms) }
                            page += 1
                        } else {
                            break
                        }
                    }
                }
                await MainActor.run { self.setLoading(false) }
            } catch {
                // On failure of region-based fetch, fallback to network paging fetch near region center
                logger.error("Region fetch failed with error: \(error). Falling back to network fetch.")
                do {
                    var page = 1
                    while page < 3 && !Task.isCancelled {
                        let fallbackRestrooms = try await restroomManager.fetchRestrooms(near: region.center, page: page)
                        if !fallbackRestrooms.isEmpty {
                            await MainActor.run { self.restrooms.formUnion(fallbackRestrooms) }
                            page += 1
                        } else {
                            break
                        }
                    }
                    await MainActor.run { self.setLoading(false) }
                } catch let error as NetworkError {
                    if case let .networkError(nestedError) = error, nestedError.localizedDescription == "cancelled" {
                        logger.info("Network cancellation successful")
                    } else {
                        await MainActor.run {
                            self.error = error
                            self.setLoading(false)
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.error = .unknownError
                        self.setLoading(false)
                    }
                }
            }
        }
    }

    private func setLoading(_ value: Bool) {
        withAnimation {
            isLoading = value
        }
    }

    func cluster(epsilon: Double) {
        clusteringTask?.cancel()
        clusteringTask = Task.detached { [weak self] in
            await self?.performClustering(epsilon: epsilon)
        }
    }

    private func performClustering(epsilon: Double) async {
        guard !restrooms.isEmpty else { return }

        // Invalidate cache if restrooms changed
        if restrooms.count != lastRestroomCount {
            cachedPoints = nil
            cachedPointLookup = nil
            lastRestroomCount = restrooms.count
        }

        // Compute or reuse points/lookup
        let points = cachedPoints ?? restrooms.map { SIMD3<Double>(x: $0.coordinate.latitude, y: $0.coordinate.longitude, z: 0.0) }
        cachedPoints = points
        let pointLookup = cachedPointLookup ?? {
            var lookup: [SIMD3<Double>: Restroom] = [:]
            for restroom in restrooms {
                let point = SIMD3<Double>(x: restroom.coordinate.latitude, y: restroom.coordinate.longitude, z: 0.0)
                lookup[point] = restroom
            }
            return lookup
        }()
        cachedPointLookup = pointLookup

        let dbscanInstance = DBSCAN(points)

        let clusters = await Task.detached {
            let (clusterPoints, _) = dbscanInstance(epsilon: epsilon, minimumNumberOfPoints: 1, distanceFunction: simd.distance)

            return clusterPoints.compactMap { cluster -> RestroomCluster? in
                guard !cluster.isEmpty else { return nil }

                let restroomsInCluster = cluster.compactMap { pointLookup[$0] }
                return restroomsInCluster.isEmpty ? nil : RestroomCluster(restrooms: restroomsInCluster)
            }
        }.value

        guard !Task.isCancelled else { return }
        var clustersWithSelection = clusters
        if let selectedCluster, !clustersWithSelection.contains(selectedCluster) {
            clustersWithSelection.append(selectedCluster)
        }

        guard !Task.isCancelled else { return }
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

    func handleClusterSelectionChange(from oldCluster: RestroomCluster?, to newCluster: RestroomCluster?, mapProxy: MapProxy, geoSize: CGSize) {
        if let newCluster {
            if let oldSelectedCluster = selectedCluster,
               newCluster.isSingle,
               oldSelectedCluster.restrooms.contains(newCluster.restrooms) {
                previousCluster = oldSelectedCluster
            } else {
                previousCluster = nil
            }
            selectAnnotation(newCluster)
            adjustMapPosition(for: newCluster, with: mapProxy, in: geoSize)
        } else {
            if let previousCluster = previousCluster {
                selectAnnotation(previousCluster)
                adjustMapPosition(for: previousCluster, with: mapProxy, in: geoSize)
            }
            if let distance = mapProxy.degreesFromPixels(clusterPixels) {
                cluster(epsilon: distance)
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
