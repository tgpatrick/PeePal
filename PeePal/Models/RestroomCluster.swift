//
//  RestroomCluster.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/14/20.
//

import Foundation
import MapKit

struct RestroomCluster {
    let restrooms: [Restroom]
    let center: CLLocationCoordinate2D
    var size: Int {
        restrooms.count
    }
    var isSingle: Bool {
        restrooms.count == 1
    }

    internal init(restrooms: [Restroom]) {
        self.restrooms = restrooms
        let intoCoord = CLLocationCoordinate2D(latitude: 0.0,longitude: 0.0)
        let factor = 1.0 / Double(restrooms.count)
        self.center = restrooms.reduce(intoCoord) { average, restroom in
            let itemCoord = restroom.coordinate
            let lat = itemCoord.latitude * factor
            let lon = itemCoord.longitude * factor
            return CLLocationCoordinate2D(latitude: average.latitude + lat, longitude: average.longitude + lon)
        }
    }
}

extension RestroomCluster: Hashable, Identifiable {
    var id: String {
        String(describing: center.latitude) + String(describing: center.longitude)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(center.latitude)
        hasher.combine(center.longitude)
    }

    static func == (lhs: RestroomCluster, rhs: RestroomCluster) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude
    }
}
