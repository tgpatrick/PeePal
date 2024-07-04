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
import OSLog

@Observable
class ContentViewModel {
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
}
