//
//  SheetViewModel.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/6/24.
//

import SwiftUI

@Observable
class SheetViewModel {
    var currentDetent: PresentationDetent = .low
    var searchField: String = ""
}

extension PresentationDetent {
    static let low: PresentationDetent = .height(75)
    static let middle: PresentationDetent = .fraction(0.4)
    static let high: PresentationDetent = .fraction(0.99)
}
