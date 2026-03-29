//
//  SearchViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/29/26.
//

import Foundation

@Observable
class SearchViewModel: ObservableObject {
    var searchText: String = ""
    var searching: Bool = false
}
