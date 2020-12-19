//
//  Neumorphism.swift
//  Puzzle Game
//
//  Created by Thomas G Patrick on 4/6/20.
//

import SwiftUI

var rotate: Animation {
    Animation.easeOut(duration: 0.75)
        .repeatForever(autoreverses: false)
}

var searchTransition: AnyTransition {
    return AnyTransition.asymmetric(
        insertion: AnyTransition.opacity.combined(with: .scale(scale: 0.5, anchor: .top)),
        removal: AnyTransition.opacity.combined(with: .scale(scale: 0.5, anchor: .top)))
}

var restroomTransition: AnyTransition {
    return AnyTransition.asymmetric(
        insertion: AnyTransition.opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)),
        removal: .identity)
}
