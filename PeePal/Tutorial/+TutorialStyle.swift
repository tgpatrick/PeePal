//
//  +TutorialStyle.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/21/26.
//

import SwiftUI

extension View {
    func tutorialTitleStyle() -> some View {
        self
            .font(.largeTitle)
            .bold()
    }
    
    func tutorialSubtitleStyle() -> some View {
        self
            .font(.title3)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    func tutorialBodyStyle() -> some View {
        self
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

extension CGFloat {
    static let tutorialContentSpacing: CGFloat = 10
}

struct TutorialImageModifer: ViewModifier {
    @State var animateIcon: Bool = false
    
    func body(content: Content) -> some View {
        content
            .symbolRenderingMode(.hierarchical)
            .symbolEffect(.bounce, value: animateIcon)
            .font(.system(size: 72, weight: .semibold))
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
            .onAppear { animateIcon.toggle() }
    }
}
