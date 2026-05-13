//
//  RestroomViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/29/26.
//

import Foundation

@Observable
class RestroomViewModel {
    static func makeAppleMapsURL(restroom: Restroom) -> URL {
        var url = "maps://?"
        url += "near=" + String(restroom.latitude) + "," + String(restroom.longitude)
        if let street = restroom.street {
            url += "&daddr=" + street
            if let city = restroom.city {
                url += ", " + city
            }
            if let state = restroom.state {
                url += ", " + state
            }
        } else if let name = restroom.name {
            url += "&q=" + (name)
        }
        url = url.replacingOccurrences(of: " ", with: "+")
        return URL(string: url) ?? URL(string: "maps://?")!
    }
    
    static func makeGoogleMapsURL(restroom: Restroom) -> URL {
        var url = "https://www.google.com/maps/dir/?api=1"
        if let street = restroom.street {
            url += "&destination=" + street
            if let city = restroom.city {
                url += "," + city
            }
            if let state = restroom.state {
                url += "," + state
            }
        } else {
            url += "&destination=" + String(restroom.latitude) + "," + String(restroom.longitude)
        }
        url = url.replacingOccurrences(of: " ", with: "+")
        url = url.replacingOccurrences(of: ",", with: "%2C")
        url = url.replacingOccurrences(of: "|", with: "%7C")
        return URL(string: url) ?? URL(string: "https://www.google.com/maps/dir/?api=1")!
    }
}
