//
//  SearchViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/14/20.
//

import Foundation
import MapKit
import OSLog
import SwiftData
import SwiftUI

@Observable
@MainActor
final class SearchViewModel: ObservableObject {
    var searchText: String = ""
    var searching: Bool = false
    var anyResults: Bool { !mapResults.isEmpty || !restroomResults.isEmpty }

    let restroomManager: RestroomManager
    
    var mapResults = [ListableItem]()
    var restroomResults = [ListableItem]()
    
    private var searchTask: Task<Void, Never>?
    private let logger = Logger.for(SearchViewModel.self)
    
    @MainActor init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }
    
    func search() {
        searchTask?.cancel()
        searchTask = Task {
            async let _ = searchMapLocations()
            async let _ = searchLocalRestrooms()
        }
    }
    
    func clear() {
        searchText.removeAll()
        mapResults.removeAll()
        restroomResults.removeAll()
    }

    private func searchMapLocations() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.pointOfInterest, .address]

        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.mapResults = Array(response.mapItems).map({ ListableItem(item: $0) })
                }
            }
        } catch {
            logger.error("Map search error: \(error.localizedDescription)")
        }
    }
    
    private func searchLocalRestrooms() async {
        do {
            let response = try await restroomManager.searchLocalRestrooms(matching: searchText)
            await MainActor.run { [weak self] in
                self?.restroomResults = response.map({ ListableItem(item: $0) })
            }
        } catch {
            logger.error("Local restroom search error: \(error.localizedDescription)")
        }
    }
}
