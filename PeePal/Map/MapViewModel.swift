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
    var showRefresh = false
    var error: NetworkError?
    var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        )
    )

    private var fetchTask: Task<Void, Never>? = nil
    private var clusteringTask: Task<Void, Never>? = nil
    private let logger = Logger()
    var locationManager = LocationManager()
    let restroomManager: RestroomManager
    let clusterPixels = 30

    private var cachedPointLookup: [SIMD3<Double>: Restroom]? = nil
    private var lastRestroomCount: Int = 0
    private var lastZoomDeltaSum: Double?
    private var lastFetchRegion: MKCoordinateRegion?
    var lastCameraContext: MapCameraUpdateContext?

    init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }

    func regionHasChanged(_ region: MKCoordinateRegion) -> Bool {
        guard let lastFetchRegion else {
            lastFetchRegion = region
            return true
        }
        let minimumDistance = 0.05
        let minimumSpanChange = 0.001
        
        let longitudeDifference = abs(lastFetchRegion.center.longitude - region.center.longitude)
        let latitudeDifference = abs(lastFetchRegion.center.latitude - region.center.latitude)
        let latitudeSpanDifference = abs(lastFetchRegion.span.latitudeDelta - region.span.latitudeDelta)
        
        
        let hasChanged = longitudeDifference > minimumDistance
        || latitudeDifference > minimumDistance
        || latitudeSpanDifference > minimumSpanChange
        
        if hasChanged {
            self.lastFetchRegion = region
            withAnimation {
                error = nil
                showRefresh = region.span.latitudeDelta < 1 && hasChanged
            }
        }
        return hasChanged
    }

    func centerOn(_ location: CLLocation) {
        withAnimation {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: location.coordinate,
                    distance: 1000
                )
            )
        }
    }
    
    func centerOnUser() {
        if let location = locationManager.location {
            centerOn(location)
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
            setLoading(true)
            try? await restroomManager.initializeFromBundleIfNeeded()
            // If a known region exists, fetch restrooms in that region to limit data
            if let region = cameraPosition.region {
                let regionRestrooms = try await restroomManager.fetchRestrooms(in: region)
                restrooms.formUnion(regionRestrooms)
                logger.info("Loaded \(regionRestrooms.count) restrooms in initial region")
            } else {
                // Fallback to loading all restrooms if no region is set
                let allRestrooms = try await restroomManager.fetchAllLocalRestrooms()
                restrooms.formUnion(allRestrooms)
                logger.info("Loaded all local restrooms (\(allRestrooms.count))")
            }
        } catch {
            logger.error("Failed to load initial restrooms: \(error)")
            self.error = .unknownError
        }
        setLoading(false)
    }

    func fetchRestrooms(region: MKCoordinateRegion? = nil, fetchFromNetwork: Bool) {
        // Cancel any ongoing fetch task to restart debounce timer
        fetchTask?.cancel()
        fetchTask = nil
        self.setLoading(false)
        
        guard let region = region ?? lastCameraContext?.region ?? lastFetchRegion else {
            // No region, no fetch
            return
        }
        self.setLoading(true)
        
        // Immediately fetch and display local restrooms for the given region
        Task {
            do {
                let localRestrooms = try await restroomManager.fetchRestrooms(in: region)
                Task { @MainActor in
                    self.restrooms = Set(localRestrooms)
                }
            } catch {
                logger.error("Failed to fetch local restrooms immediately: \(error)")
                self.error = .unknownError
            }
        }
        
        // Don't fetch when zoomed out, that's not really useful
        guard fetchFromNetwork && region.span.latitudeDelta < 1 else {
            setLoading(false)
            return
        }
        
        // Start debounced network fetch task
        fetchTask = Task.detached { [weak self] in
            guard let self else { return }
            await MainActor.run {
                self.setLoading(true)
                self.showRefresh = false
            }

            let d = region.span.latitudeDelta
            let numPages: Int
            switch d {
            case ..<0.05: numPages = 1
            case ..<0.1: numPages = 2
            case ..<0.25: numPages = 3
            case ..<0.5: numPages = 4
            case ..<1: numPages = 5
            default: numPages = 6
            }
            do {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for page in 1...numPages {
                        group.addTask { [weak self] in
                            guard let self else { return }
                            do {
                                let networkRestrooms = try await self.restroomManager.fetchRestrooms(near: region.center, page: page)
                                guard !networkRestrooms.isEmpty else { return }

                                try Task.checkCancellation()
                                // Save fetched restrooms to local storage before next page
                                await self.saveNewRestrooms(networkRestrooms)

                                let updatedLocalRestrooms = try await self.restroomManager.fetchRestrooms(in: region)
                                await MainActor.run {
                                    if !updatedLocalRestrooms.isEmpty {
                                        self.restrooms = Set(updatedLocalRestrooms)
                                    }
                                }
                            } catch {
                                throw error
                            }
                        }
                    }
                    // Drain the group to surface any thrown error
                    try await group.waitForAll()
                }
            } catch {
                if let error = error as? NetworkError {
                   if case let .networkError(nestedError) = error,
                      nestedError.localizedDescription == "cancelled" {
                       self.logger.info("Network cancellation successful")
                       return
                   } else {
                       await MainActor.run {
                           self.error = error
                       }
                   }
                } else {
                    await MainActor.run {
                        self.error = .unknownError
                    }
                }
            }

            // All tasks finished (or error handled); stop loading
            await MainActor.run {
                self.setLoading(false)
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
        clusteringTask = nil
        clusteringTask = Task.detached { [weak self] in
            await self?.performClustering(epsilon: epsilon)
        }
    }

    private func performClustering(epsilon: Double) async {
        guard !restrooms.isEmpty else { return }

        // Invalidate cache if restrooms changed
        if restrooms.count != lastRestroomCount {
            lastRestroomCount = restrooms.count
        }

        // Compute or reuse points/lookup
        let points = restrooms.map { SIMD3<Double>(x: $0.coordinate.latitude, y: $0.coordinate.longitude, z: 0.0) }
        let pointLookup = await getOrGenerateCachedPointLookup()
        let dbscanInstance = DBSCAN(points)

        let clusters = await Task.detached {
            let (clusterPoints, outliers) = dbscanInstance(epsilon: epsilon, minimumNumberOfPoints: 2, distanceFunction: simd.distance)

            let actualClusters = clusterPoints.compactMap { cluster -> RestroomCluster? in
                guard !cluster.isEmpty else { return nil }

                let restroomsInCluster = cluster.compactMap { pointLookup[$0] }
                return restroomsInCluster.isEmpty ? nil : RestroomCluster(restrooms: restroomsInCluster)
            }
            let individualRestrooms = outliers.compactMap { pointLookup[$0] }
            return actualClusters + individualRestrooms.compactMap { RestroomCluster(restrooms: [$0]) }
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
    
    private func saveNewRestrooms(_ newRestrooms: [Restroom]) async {
        do {
            try await restroomManager.save(newRestrooms)
            var lookup = await getOrGenerateCachedPointLookup()
            for restroom in newRestrooms {
                let point = SIMD3<Double>(x: restroom.coordinate.latitude, y: restroom.coordinate.longitude, z: 0.0)
                lookup[point] = restroom
            }
            cachedPointLookup = lookup
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func getOrGenerateCachedPointLookup() async -> [SIMD3<Double>: Restroom] {
        if let cachedPointLookup { return cachedPointLookup }
        guard let restrooms = try? await restroomManager.fetchAllLocalRestrooms() else { return [:] }
        var lookup: [SIMD3<Double>: Restroom] = [:]
        for restroom in restrooms {
            let point = SIMD3<Double>(x: restroom.coordinate.latitude, y: restroom.coordinate.longitude, z: 0.0)
            lookup[point] = restroom
        }
        cachedPointLookup = lookup
        return lookup
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
        guard let clusterPoint = mapProxy.convert(cluster.center, to: .local)
        else { return }
        
        var center = CGPoint(x: size.width / 2, y: size.height / 2)
        var shouldUpdate = false

        let topEdge = size.height * 0.1
        let bottomEdge = size.height * 0.55
        let leadingEdge = size.width * 0.125
        let trailingEdge = size.width * 0.875

        if clusterPoint.y > bottomEdge {
            let pixelsToMove = clusterPoint.y - bottomEdge
            center.y += pixelsToMove
            shouldUpdate = true
        } else if clusterPoint.y < topEdge {
            let pixelsToMove = clusterPoint.y - topEdge
            center.y += pixelsToMove
            shouldUpdate = true
        }

        if clusterPoint.x < leadingEdge {
            let pixelsToMove = clusterPoint.x - leadingEdge
            center.x += pixelsToMove
            shouldUpdate = true
        } else if clusterPoint.x > trailingEdge {
            let pixelsToMove = clusterPoint.x - trailingEdge
            center.x += pixelsToMove
            shouldUpdate = true
        }

        guard shouldUpdate, let newCenter = mapProxy.convert(center, from: .local) else { return }
        withAnimation {
            guard var newCamera = lastCameraContext?.camera else {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: lastCameraContext?.region.span != nil ? newCenter : cluster.center,
                        span: lastCameraContext?.region.span ??
                        MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    )
                )
                return
            }
            newCamera.centerCoordinate = newCenter
            cameraPosition = .camera(newCamera)
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
