//
//  ContentViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/3/24.
//

import Foundation
import CoreLocation
import Observation

@Observable
class ContentViewModel {
    var restrooms: Set<Restroom> = []
    var isLoading = false
    var error: NetworkError?

    private let locationManager = LocationManager()

    func fetchRestrooms() async {
        isLoading = true
        defer { isLoading = false }

        do {
            locationManager.requestLocation()
            guard let location = await waitForLocation() else {
                throw NetworkError.locationNotAvailable
            }
            restrooms = Set(try await RestroomService.fetchRestrooms(near: location))
        } catch let error as NetworkError {
            self.error = error
        } catch {
            self.error = .unknownError
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
