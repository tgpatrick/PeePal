//
//  LocationManager.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/13/20.
//

import Foundation
import CoreLocation

@Observable
class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    var location: CLLocation?
    var locationError: Error?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        requestLocation()
        guard let location else { return nil }
        let coordinateCLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return location.distance(from: coordinateCLLocation)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
    }
}
