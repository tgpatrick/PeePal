//
//  SearchManager.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/13/24.
//

import Foundation
import MapKit
import OSLog

@Observable
class SearchManager: NSObject {
    var completions: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()
    private let logger = Logger()

    override init() {
        super.init()
        completer.resultTypes = .address
        completer.delegate = self
    }

    func search(for term: String) {
        completer.queryFragment = term
    }
}

extension SearchManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        logger.error("Search error: \(error.localizedDescription)")
    }
}
