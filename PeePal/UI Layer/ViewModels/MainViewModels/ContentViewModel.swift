//
//  ContentViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
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
    var isLoading = false
    var error: NetworkError?
    var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))

    var searchField: String = ""

    private var fetchTask: Task<Void, Error>? = nil
    private let logger = Logger()
    private let locationManager = LocationManager()

    func fetchRestrooms(region: MKCoordinateRegion? = nil) {
        fetchTask?.cancel()

        fetchTask = Task {
            guard let fetchRegion = region ?? cameraPosition.region else { return }
            do {
                var page = 1
                while page < 5 && !Task.isCancelled {
                    if !isLoading {
                        withAnimation {
                            isLoading = true
                        }
                    }
                    let newRestrooms = try await RestroomService.fetchRestrooms(near: fetchRegion.center, page: page)
                    if !newRestrooms.isEmpty {
                        restrooms.formUnion(newRestrooms)
                        page += 1
                    } else {
                        break
                    }
                }
                withAnimation {
                    isLoading = false
                }
            } catch let error as NetworkError {
                if case let .networkError(nestedError) = error, nestedError.localizedDescription == "cancelled" {
                    logger.info("Network cancellation successful")
                } else {
                    self.error = error
                    withAnimation {
                        isLoading = false
                    }
                }
            } catch {
                self.error = .unknownError
                withAnimation {
                    isLoading = false
                }
            }
        }
    }

    private func waitForLocation() async -> CLLocation? {
        let maxAttempts = 10
        let delayInterval: TimeInterval = 1.0 // 1 second

        for _ in 0..<maxAttempts {
            if let location = locationManager.location {
                return location
            }
            try? await Task.sleep(for: .seconds(delayInterval))
        }
        return nil
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
        
        let newClusters = await dbScanTask.value
        await MainActor.run {
            self.clusters = newClusters
        }
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
