//
//  GlassyToolbarButton.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/11/26.
//

import SwiftUI

struct GlassyToolbarButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
        } else {
            configuration.label
                .padding(3)
                .background(
                    Circle()
                        .fill(.regularMaterial)
                )
                .opacity(configuration.isPressed ? 0.3 : 1)
        }
    }
}

struct GlassyOrProminentButton: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
        } else {
            content
                .compositingGroup()
                .shadow(radius: 5)
                .buttonStyle(.borderedProminent)
        }
    }
}
