//
//  View+PresentationBackground.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/4/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func materialPresentationBackground(_ enabled: Bool) -> some View {
        if enabled {
            self.presentationBackground(.ultraThickMaterial)
        } else {
            self
        }
    }
}
