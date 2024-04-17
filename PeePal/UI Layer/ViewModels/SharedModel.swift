//
//  ViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI
import MapKit
import CoreLocation

class SharedModel: ObservableObject {
    @Published var settings = AppSettings()
    @Published var filters = Filters()
    @Published var cvm = ContentViewModel()
    @Published var svm = SearchViewModel()
    var appLogic: AppLogic = AppLogic(settings: AppSettings(), filters: Filters())
    
    @Published var seenTutorial = UserDefaults.standard.bool(forKey: "seenTutorial")
    @Published var showTutorial: Bool = false
    
    @Published var restrooms: [Restroom] = []
    @Published var loadingRestrooms: Bool = false
    var responses: [Restroom] = []
    
    @Published var locationManager = LocationManager()
    
    @Published var loadingTask: Task<(), Never>?
    
    init() {
        appLogic = AppLogic(settings: settings, filters: filters)
        showTutorial = !seenTutorial
        if settings.numPerPage == 0 {
            settings.numPerPage = 100
        }
    }
    
    func getRestrooms(page: Int = 1, loadedSoFar: Int = 0, group: DispatchGroup?, forSearch: Bool = false, savedSearch: String = "") {
        var thisSearch: String = ""
        if page == 1 {
            self.loadingRestrooms = true
            if !forSearch {
                cvm.loadLocation = cvm.region
            }
        }
        if forSearch {
            if savedSearch == "" {
                thisSearch = svm.searchText
            } else {
                thisSearch = savedSearch
            }
        }
        if (!forSearch && cvm.region.span.latitudeDelta < 0.1) || forSearch {
            var url: URL
            if !forSearch {
                url = URL(string: appLogic.makeLocationURL(region: cvm.region, page: page, perPage: 20))!
            } else {
                if svm.searchText == "" {
                    return
                }
                url = URL(string: appLogic.makeSearchURL(searchText: svm.searchText, page: page, perPage: 20))!
            }
            let request = URLRequest(url: url)
            if let loadingTask {
                loadingTask.cancel()
            }
            loadingTask = Task {
                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    if !forSearch {
                        if let decodedResponse = try? JSONDecoder().decode([Restroom].self, from: data) {
                            if (decodedResponse.count > 0) {
                                DispatchQueue.main.async {
                                    // Remove duplicates, then only keep the closest
                                    let deDuplicatedRestrooms = Set(decodedResponse)
                                    var combined = Array(Set(self.restrooms).union(deDuplicatedRestrooms))
                                    for (index, restroom) in combined.enumerated() {
                                        combined[index].distance = restroom.distanceFrom(self.cvm.region.center)
                                    }
                                    let indexEnd = min(self.settings.numPerPage, combined.count) - 1
                                    combined = Array(combined.sorted()[...indexEnd])
                                    withAnimation {
                                        self.restrooms = combined
                                    }
                                    if loadedSoFar + deDuplicatedRestrooms.count < self.settings.numPerPage {
                                        self.getRestrooms(page: page + 1, loadedSoFar: loadedSoFar + deDuplicatedRestrooms.count, group: group)
                                    } else {
                                        self.loadingRestrooms = false
                                        group?.leave()
                                    }
                                }
                            } else {
                                group?.leave()
                                self.loadingRestrooms = false
                            }
                            return
                        } else {
                            print("Failed to decode data")
                            return
                        }
                    } else {
                        if let decodedResponse = try? JSONDecoder().decode([SearchRestroom].self, from: data) {
                            let headers = (response as! HTTPURLResponse).allHeaderFields
                            let totalPages = headers["X-Total-Pages"] as! String
                            if (decodedResponse.count > 0) {
                                DispatchQueue.main.async {
                                    //update the UI
                                    if thisSearch == self.svm.searchText {
                                        self.svm.searchResults += decodedResponse
                                    }
                                    group?.leave()
                                    if ((Int(totalPages) ?? 0 > page)) {
                                        self.getRestrooms(page: page + 1, group: nil, forSearch: true, savedSearch: thisSearch)
                                    } else {
                                        self.loadingRestrooms = false
                                    }
                                }
                            } else {
                                group?.leave()
                                self.loadingRestrooms = false
                            }
                            return
                        } else {
                            print("Failed to decode search data:")
                            return
                        }
                    }
                } catch {
                    print("Network error: \(error)")
                }
            }
        } else {
            group?.leave()
            self.loadingRestrooms = false
        }
    }
    
    func clearData() {
        loadingTask?.cancel()
        withAnimation {
            self.restrooms = []
        }
    }

    func loadNew() {
        self.getRestrooms(group: nil)
    }
    
    func reload() {
        clearData()
        self.getRestrooms(group: nil)
    }
    
    func clearScreen() {
        loadingTask?.cancel()
        withAnimation {
            svm.searchText = ""
            svm.searching = false
            svm.searchResults = []
            cvm.clearScreen()
        }
    }
    
    func getCurrentCoords() -> CLLocationCoordinate2D {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(locationManager.lastLocation?.coordinate.latitude ?? 37),
            longitude: CLLocationDegrees(locationManager.lastLocation?.coordinate.longitude ?? -96))
        return coordinates
    }
    
    func reCenter(group: DispatchGroup?) {
        cvm.moveMap(coords: getCurrentCoords())
        if Float(cvm.region.center.latitude) != 37 {
            cvm.region.span = MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01)
        }
    }
    
    func getClosest() -> Restroom? {
        if let firstRestroom = self.restrooms.first {
            var closest: Restroom = firstRestroom
            for restroom in self.restrooms {
                if restroom.distance ?? 1000 < closest.distance ?? 1000 {
                    closest = restroom
                }
            }
            return closest
        } else if (cvm.region.span.latitudeDelta < 0.1 && !loadingRestrooms) {
            self.cvm.showAdd = true
            return nil
        }
        return nil
    }
    
    func urgent() {
        let group = DispatchGroup()
        if !settings.useRegion {
            reCenter(group: group)
        }
        group.enter()
        self.getRestrooms(group: group)
        group.notify(queue: .main) {
            let closest = self.getClosest()
            if closest != nil {
                self.cvm.showDetail(restroom: closest!)
            }
        }
    }
    
    func search() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.svm.searching = true
        }
        let group = DispatchGroup()
        group.enter()
        self.getRestrooms(page: 1, group: group, forSearch: true)
        group.notify(queue: .main) {
            self.svm.searching = false
        }
    }
}

