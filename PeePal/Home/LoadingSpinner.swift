//
//  LoadingSpinner.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/2/26.
//

import SwiftUI

struct LoadingSpinner: View {
    @State private var animateLoader = false
    
    var body: some View {
        ZStack {
            Image(systemName: "aqi.medium")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color(.unisex))
                .symbolEffect(
                    .variableColor.iterative,
                    options: .repeating.speed(0.5),
                    value: animateLoader)
            Image(systemName: "arrow.triangle.2.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
                .foregroundStyle(Color(.unisex))
                .rotationEffect(Angle(
                    degrees: animateLoader ? 360 : 0))
                .animation(
                    .easeInOut(duration: 1).repeatForever(autoreverses: false),
                    value: animateLoader)
        }
        .padding(-4)
        .background {
            Circle().foregroundStyle(.ultraThickMaterial)
        }
        .compositingGroup()
        .shadow(radius: 5)
        .zIndex(2)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            withAnimation {
                animateLoader = true
            }
        }
        .onDisappear { animateLoader = false }
    }
}
