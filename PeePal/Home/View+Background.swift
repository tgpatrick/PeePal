//
//  View+Background.swift
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
    
    func colorCircleShadow(_ color: Color) -> some View {
        self.background {
            Circle()
                .fill(color)
                .padding(10)
                .shadow(color: color, radius: 5)
                .shadow(color: color, radius: 5)
                .shadow(color: color, radius: 5)
        }
    }
}
