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

@Observable
class ContentViewModel {
    var restrooms: Set<Restroom> = []
    var isLoading = false
    var error: NetworkError?
    var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))

    private let locationManager = LocationManager()

    func fetchRestrooms(region: MKCoordinateRegion? = nil) {
        isLoading = true
        defer { isLoading = false }
        Task {
            guard let fetchRegion = region ?? cameraPosition.region else { return }
            do {
                let newRestrooms = try await RestroomService.fetchRestrooms(near: fetchRegion.center)
                await MainActor.run {
                    withAnimation {
                        restrooms.formUnion(newRestrooms)
                    }
                }
            } catch let error as NetworkError {
                self.error = error
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
