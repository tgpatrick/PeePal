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
    var isLoading = false
    var error: NetworkError?
    var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))

    private var fetchTask: Task<Void, Error>? = nil
    private let logger = Logger()
    private let locationManager = LocationManager()

    func fetchRestrooms(region: MKCoordinateRegion? = nil) {
        isLoading = true
        fetchTask?.cancel()
        defer { isLoading = false }

        fetchTask = Task {
            guard let fetchRegion = region ?? cameraPosition.region else { return }
            do {
                var page = 1
                while true {
                    let newRestrooms = try await RestroomService.fetchRestrooms(near: fetchRegion.center, page: page)
                    if !newRestrooms.isEmpty {
                        withAnimation {
                            restrooms.formUnion(newRestrooms)
                        }
                        page += 1
                    } else {
                        break
                    }
                }
            } catch let error as NetworkError {
                if case let .networkError(nestedError) = error, nestedError.localizedDescription == "cancelled" {
                    logger.info("Network cancellation successful")
                } else {
                    self.error = error
                }
            } catch {
                self.error = .unknownError
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

    func cluster(epsilon : Double ) async {
        guard !restrooms.isEmpty else { return }

        let dbScanTask = Task { () -> [RestroomCluster] in

            // put the locations in a format that DBSCAN can use
            var input: [SIMD3<Double>] = []
            for restroom in restrooms {
                let coord = restroom.coordinate
                let vector = SIMD3<Double>(x:coord.latitude, y:coord.longitude, z:0.0)
                input.append(vector)
            }

            // create and run DBSCAN on the locations data
            let dbscan = DBSCAN(input)
            let (clusters, _) = dbscan(epsilon: epsilon, minimumNumberOfPoints: 1, distanceFunction: simd.distance)

            // return an array of PlaceClusters matching the clusters returned by DBSCAN
            var foundClusters = [RestroomCluster]()
            for (_, cluster) in clusters.enumerated() {
                var restroomsCluster = [Restroom]()
                if cluster.count > 0 {
                    for p in cluster {
                        if let item = restrooms.first(where: { $0.coordinate.latitude == p.x && $0.coordinate.longitude == p.y }) {
                            restroomsCluster.append(item)
                        }
                    }
                    let pointCluster = RestroomCluster(restrooms: restroomsCluster)
                    foundClusters.append(pointCluster)
                }
            }
            return (foundClusters)
        }

        self.clusters = await dbScanTask.value
    }
}

extension MapProxy {
    func degrees( fromPixels pixels : Int ) -> Double? {
        let c1 = self.convert(CGPoint.zero, from: .global)
        let p2 = CGPoint(x: Double(pixels), y: 0.0 )
        let c2 = self.convert(p2, from: .global)
        if let lon1 = c1?.longitude, let lon2 = c2?.longitude {
            return abs(lon1 - lon2)
        }
        return nil
    }
}
