//
//  AppLogic.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI
import MapKit

class AppLogic {
    @ObservedObject var settings: AppSettings
    @ObservedObject var filters: Filters
    
    init(settings: AppSettings, filters: Filters) {
        self.settings = settings
        self.filters = filters
    }
    
    func makeLocationURL(region: MKCoordinateRegion, page: Int, perPage: Int = 10) -> String {
        let baseURL = "https://www.refugerestrooms.org/api/v1/restrooms/by_location?"
        var url: String = baseURL
        url += "page=" + String(page)
        url += "&per_page=" + String(perPage)
        url += "&offset=" + String(0)
        if filters.accessFilter {
            url += "&ada=true"
        }
        if filters.unisexFilter {
            url += "&unisex=true"
        }
        url += "&lat=" + String(region.center.latitude)
        url += "&lng=" + String(region.center.longitude)
//        print(url)
        return url
    }
    
    func makeSearchURL(searchText: String, page: Int, perPage: Int = 10) -> String {
        let baseURL = "https://www.refugerestrooms.org/api/v1/restrooms/search?"
        var url: String = baseURL
        url += "page=" + String(page)
        url += "&per_page=" + String(perPage)
        url += "&offset=" + String(0)
        if !settings.searchIgnoreFilters {
            if filters.accessFilter {
                url += "&ada=true"
            }
            if filters.unisexFilter {
                url += "&unisex=true"
            }
        }
        url += "&query=" + toParam(string: searchText)
//        print(url)
        return url
    }
    
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
            url += "&q=" + (restroom.name ?? "")
        }
        url = url.replacingOccurrences(of: " ", with: "+")
        return URL(string: url) ?? URL(string: "maps://?")!
    }
    
    func makeGoogleMapsURL(restroom: Restroom) -> URL {
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
    
    func directionsURL(restroom: Restroom) -> URL {
        if !settings.useGoogle {
            return AppLogic.makeAppleMapsURL(restroom: restroom)
        } else {
            return makeGoogleMapsURL(restroom: restroom)
        }
    }
    
    static func makeEditURL(restroom: Restroom) -> URL {
        var url = "https://www.refugerestrooms.org/restrooms/"
        url += String(restroom.id)
        return URL(string: url) ?? URL(string: "https://www.refugerestrooms.org")!
    }
    
    func toParam(string: String) -> String {
        var param: String = ""
        for char in string {
            if char == " " {
                param.append("%20")
            } else {
                param.append(char)
            }
        }
        return param
    }
    
    func searchToReal(searchRestroom: SearchRestroom) -> Restroom {
        return Restroom(
            id: searchRestroom.id,
            name: searchRestroom.name,
            street: searchRestroom.street,
            accessible: searchRestroom.accessible,
            unisex: searchRestroom.unisex,
            changingTable: searchRestroom.changing_table,
            distance: 0,
            comment: searchRestroom.comment,
            directions: searchRestroom.directions,
            downvote: searchRestroom.downvote,
            upvote: searchRestroom.upvote,
            latitude: searchRestroom.latitude,
            longitude: searchRestroom.longitude)
    }
}
