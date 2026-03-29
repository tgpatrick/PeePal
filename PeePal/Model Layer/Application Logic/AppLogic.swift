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
