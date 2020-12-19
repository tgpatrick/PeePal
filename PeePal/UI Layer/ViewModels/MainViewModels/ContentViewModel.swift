//
//  ContentViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI
import MapKit

class ContentViewModel: ObservableObject {
    @ObservedObject var settings = AppSettings()
    
    @Published var showFilter = false
    @Published var showSearch: Bool = false
    @Published var showSettings = false
    @Published var showAdd: Bool = false
    
    @Published var showDetail = false
    @Published var detailRestroom: Restroom = exampleRestroom
    @Published var detailRegion = MKCoordinateRegion()
    @Published var reloadDistance: Float = 0.04
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37,
            longitude: -96),
        span: MKCoordinateSpan(
            latitudeDelta: 30,
            longitudeDelta: 30)
    )
    @Published var loadLocation = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37,
            longitude: -96),
        span: MKCoordinateSpan(
            latitudeDelta: 30,
            longitudeDelta: 30)
    )
    
    @Published var loadingAngle: Double = 0
    
    let appLogic = AppLogic(settings: AppSettings(), filters: Filters())
    
    init() {
        loadLocation = region
        reloadDistance = Float(settings.numPerPage) * 0.0004
    }
    
    func moveMap(coords: CLLocationCoordinate2D) {
        region.center = coords
    }
    
    func showDetail(restroom: Restroom) {
            moveMap(coords: restroom.getCoordinates())
            detailRestroom = restroom
            detailRegion = region
            var waitTime = 0.1
            if region.span.latitudeDelta * 9 > waitTime {
                waitTime = region.span.latitudeDelta * 9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                if !self.showDetail {
                    withAnimation {
                        self.showDetail = true
                    }
                }
            }
    }
    
    func filterButton() {
        withAnimation {
            if !showFilter {
                clearScreen()
                detailRegion = region
                showFilter.toggle()
            } else {
                clearScreen()
            }
        }
    }
    
    func settingsButton() {
        clearScreen()
        showSettings.toggle()
    }
    
    func getCoordinates(restroom: Restroom) -> CLLocationCoordinate2D {
        return restroom.getCoordinates()
    }
    
    func clearScreen() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        showAdd = false
        showDetail = false
        showFilter = false
        showSearch = false
    }
}
