//
//  SearchViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/14/20.
//

import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searching: Bool = false
    @Published var searchText: String = ""
    @Published var searchResults: [SearchRestroom] = []
    @Published var spinning = false
}
