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
    var selectedMapItem: MKMapItem?
    var selectedCluster: RestroomCluster?
    var parentCluster: RestroomCluster?
    var isLoading = false
    var error: NetworkError?
    var cameraPosition: MapCameraPosition = .rect(
        MKMapRect(
            origin: MKMapPoint(
                CLLocationCoordinate2D(
                    latitude: 40.7128,
                    longitude: -74.0060
                )
            ),
            size: MKMapSize(
                width: 100_000,
                height: 100_000
            )
        )
    )

    private var fetchTask: Task<Void, Never>? = nil
    private var clusteringTask: Task<Void, Never>? = nil
    private let logger = Logger()
    let locationManager = LocationManager.shared
    let restroomManager: RestroomManager
    let clusterPixels = 30

    private var cachedPoints: [SIMD3<Double>]? = nil
    private var cachedPointLookup: [SIMD3<Double>: Restroom]? = nil
    private var lastRestroomCount: Int = 0
    private var lastZoomDeltaSum: Double?
    private var lastCameraRegion: MKCoordinateRegion?

    init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }

    func regionHasChanged(_ region: MKCoordinateRegion) -> Bool {
        guard let lastCameraRegion else {
            lastCameraRegion = region
            return true
        }
        let minimumDistance = 0.05
        
        let longitudeDifference = abs(lastCameraRegion.center.longitude - region.center.longitude)
        let latitudeDifference = abs(lastCameraRegion.center.latitude - region.center.latitude)
        
        self.lastCameraRegion = region
        return longitudeDifference > minimumDistance || latitudeDifference > minimumDistance
    }

    func centerOn(_ location: CLLocation) {
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    func focusOn(_ item: any Listable) {
        if let mapItem = item as? MKMapItem {
            selectedMapItem = mapItem
            selectedCluster = mapItemCluster
            if #available(iOS 26.0, *) {
                centerOn(mapItem.location)
            } else if let location = mapItem.placemark.location {
                centerOn(location)
            }
        } else if let restroomItem = item as? Restroom {
            selectedCluster = RestroomCluster(restrooms: [restroomItem])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.centerOn(CLLocation(coordinate: restroomItem.coordinate))
            })
        }
    }
    
    func setInitialCameraPosition() {
        locationManager.requestLocation()
    }

    func loadInitialRestrooms() async {
        do {
            isLoading = true
            try? await restroomManager.initializeFromBundleIfNeeded()
            // If a known region exists, fetch restrooms in that region to limit data
            if let region = cameraPosition.region {
                let regionRestrooms = try await restroomManager.fetchRestrooms(in: region)
                restrooms.formUnion(regionRestrooms)
                logger.info("Loaded \(regionRestrooms.count) restrooms in initial region")
            } else {
                // Fallback to loading all restrooms if no region is set
                let allRestrooms = try await restroomManager.fetchAllRestrooms()
                restrooms.formUnion(allRestrooms)
                logger.info("Loaded all local restrooms (\(allRestrooms.count))")
            }
        } catch {
            logger.error("Failed to load initial restrooms: \(error)")
            self.error = .unknownError
        }
        isLoading = false
    }

    func fetchRestrooms(region: MKCoordinateRegion? = nil) {
        // Cancel any ongoing fetch task to restart debounce timer
        fetchTask?.cancel()
        self.setLoading(false)
        
        guard let region = region ?? cameraPosition.region else {
            // No region, no fetch
            return
        }
        
        // Immediately fetch and display local restrooms for the given region
        Task { @MainActor in
            do {
                let localRestrooms = try await restroomManager.fetchRestrooms(in: region)
                self.restrooms = Set(localRestrooms)
            } catch {
                logger.error("Failed to fetch local restrooms immediately: \(error)")
                self.error = .unknownError
            }
        }
        
        // Don't fetch when zoomed out, that's not really useful
        guard region.span.latitudeDelta < 1 else { return }
        
        // Start debounced network fetch task
        fetchTask = Task.detached { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            
            guard let self, !Task.isCancelled else { return }
            await MainActor.run { self.setLoading(true) }
            
            do {
                var page = 1
                while page < 5 && !Task.isCancelled {
                    let networkRestrooms = try await self.restroomManager.fetchRestrooms(near: region.center, page: page)
                    if networkRestrooms.isEmpty { break }
                    
                    // Save fetched restrooms to local storage before next page
                    try await self.restroomManager.save(networkRestrooms)
                    let updatedLocalRestrooms = try await self.restroomManager.fetchRestrooms(in: region)
                    await MainActor.run {
                        if self.restrooms.count == updatedLocalRestrooms.count {
                            self.fetchTask?.cancel()
                            return
                        } else {
                            self.restrooms = Set(updatedLocalRestrooms)
                        }
                    }
                    page += 1
                }
                await MainActor.run { self.setLoading(false) }
            } catch let error as NetworkError {
                if case let .networkError(nestedError) = error, nestedError.localizedDescription == "cancelled" {
                    self.logger.info("Network cancellation successful")
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
    
    func clearSelectedAnnotation() {
        selectedCluster = nil
    }

    func selectAnnotation(_ cluster: RestroomCluster) {
        // If selecting restroom from search, make sure there are no duplicates
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
            // If selecting a single restroom from a cluster, save parent cluster
            if let oldCluster,
               newCluster.isSingle,
               oldCluster.restrooms.contains(newCluster.restrooms) {
                parentCluster = oldCluster
            } else {
                parentCluster = nil
            }
            selectAnnotation(newCluster)
            adjustMapPosition(for: newCluster, with: mapProxy, in: geoSize)
        } else if let parentCluster {
            // If unselecting a single restroom, focus parent cluster if there is one
            if let oldCluster {
                clusters.removeAll(
                    where: {
                        $0.restrooms.contains(oldCluster.restrooms)
                    })
            }
            selectAnnotation(parentCluster)
            adjustMapPosition(for: parentCluster, with: mapProxy, in: geoSize)
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

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

let mapItemCluster = RestroomCluster(
    restrooms: [
        Restroom(
            id: -1,
            accessible: false,
            unisex: false,
            changingTable: false,
            downvote: 0,
            upvote: 0,
            latitude: 0,
            longitude: 0
        )
    ]
)
