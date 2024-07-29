//
//  SheetViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/6/24.
//

import SwiftUI
import MapKit

@Observable
class SheetViewModel {
    var currentDetent: PresentationDetent = .low
    var searchField: String = ""
    var searchResults: [ListableItem] {
        mapResults.map({ ListableItem(item: $0) }) + restroomResults.map({ ListableItem(item: $0) })
    }

    private var mapResults = [MKMapItem]()
    private var restroomResults = [Restroom]()

    func searchLocations() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchField
        request.resultTypes = [.pointOfInterest, .address]

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.mapResults = Array(response.mapItems.prefix(25))
        }
    }
}

extension PresentationDetent {
    static let low: PresentationDetent = .height(75)
    static let middle: PresentationDetent = .fraction(0.4)
    static let high: PresentationDetent = .fraction(0.99)
}
