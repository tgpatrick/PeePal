//
//  Listable.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/14/24.
//

import Foundation
import MapKit

protocol Listable: Hashable {
    var fullName: String { get }
    var fullAddress: String { get }
    var coordinate: CLLocationCoordinate2D { get }
}

extension Restroom: Listable {
    var fullName: String {
        name ?? "Name Unknown"
    }
    
    var fullAddress: String {
        var address = ""
        if let street {
            address += street
        }
        if let city {
            address += " "
            address += city
        }
        if let state {
            address += ", "
            address += state
        }
        return address
    }
}

extension MKMapItem: Listable {
    var fullName: String {
        name ?? "Name Unknown"
    }
    
    var fullAddress: String {
        var components: [String] = []

        if let streetNumber = placemark.subThoroughfare, let streetName = placemark.thoroughfare {
            components.append("\(streetNumber) \(streetName)")
        } else if let streetName = placemark.thoroughfare {
            components.append(streetName)
        }

        if let city = placemark.locality {
            components.append(city)
        }

        if let state = placemark.administrativeArea, let postalCode = placemark.postalCode {
            components.append("\(state) \(postalCode)")
        } else if let state = placemark.administrativeArea {
            components.append(state)
        } else if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        if let country = placemark.country, country != "United States" {
            components.append(country)
        }

        return components.compactMap { $0 }.joined(separator: ", ")
    }
    
    var coordinate: CLLocationCoordinate2D {
        placemark.coordinate
    }
}
