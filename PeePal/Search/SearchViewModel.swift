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
    
    var currentSuggestion: String?
    private var suggestionTimer: Timer?
    private let searchSuggestions: [String] = [
        "Cafés", "Gas Stations", "Hospitals", "Cities", "Grocery Stores", "Bagel Shops",
        "Pharmacies", "Dog Parks", "ATM Machines", "Charging Stations", "Pizza Parlors",
        "Museums", "Hotels", "Restaurants", "Libraries", "Post Offices", "Movie Theaters",
        "Bookstores", "Parks", "Aquariums", "Bike Repair Shops", "Bowling Alleys",
        "Ice Cream Shops", "Haunted Houses", "Secret Lairs", "Unicorn Sanctuaries",
        "Countries", "Mountains", "Universities", "Government Buildings", "Beaches",
        "Discotheques", "Art Galleries", "Botanical Gardens", "Zombie Apocalypse Shelters"
    ]

    let restroomManager: RestroomManager
    
    var mapResults = [ListableItem]()
    var restroomResults = [ListableItem]()
    
    var loadingNetworkResults: Bool = false
    private var searchTask: Task<Void, Never>?
    private let logger = Logger.for(SearchViewModel.self)
    
    @MainActor init(modelContext: ModelContext) {
        self.restroomManager = RestroomManager(modelContext: modelContext)
    }
    
    func search() {
        logger.debug("Searching for: \(self.searchText)")
        searchTask?.cancel()
        searchTask = nil
        searchTask = Task {
            async let _ = searchMapLocations()
            async let _ = searchLocalRestrooms()
            try? await Task.sleep(for: .seconds(1))
            try? Task.checkCancellation()
            await searchRemoteRestrooms()
        }
    }
    
    func clear() {
        searchText.removeAll()
        mapResults.removeAll()
        restroomResults.removeAll()
    }
    
    func startSuggestionAnimation() {
        suggestionTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] timer in
            let newSuggestion = self?.searchSuggestions.randomElement()
            Task { @MainActor in
                withAnimation {
                    self?.currentSuggestion = newSuggestion
                }
            }
        }
    }
    
    func stopSuggestionAnimation() {
        suggestionTimer?.invalidate()
    }

    private func searchMapLocations() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.pointOfInterest, .address]

        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            try? Task.checkCancellation()
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
            try? Task.checkCancellation()
            await MainActor.run { [weak self] in
                self?.restroomResults = response.map({ ListableItem(item: $0) })
            }
        } catch {
            logger.error("Local restroom search error: \(error.localizedDescription)")
        }
    }
    
    func searchRemoteRestrooms() async {
        guard searchText.count > 3 else { return }
        defer {
            withAnimation {
                self.loadingNetworkResults = false
            }
        }
        
        do {
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.loadingNetworkResults = true
                }
            }
            let response = try await restroomManager.searchRemoteRestrooms(matching: searchText)
            let currentRestrooms = Set<ListableItem>(restroomResults)
            let newResults = currentRestrooms.union(Set<ListableItem>(response.map({ ListableItem(item: $0) })))
            try? Task.checkCancellation()
            await MainActor.run { [weak self] in
                self?.restroomResults = Array(newResults)
            }
        } catch {
            var description = ""
            if let error = error as? NetworkError {
                description = error.description
            } else {
                description = error.localizedDescription
            }
            logger.error("Remote restroom search error: \(description)")
        }
    }
}

