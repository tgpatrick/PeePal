//
//  MapTutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/21/26.
//

import SwiftUI

struct MapTutorialView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: .mapCircleIcon)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 72, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("The map")
                    .font(.largeTitle).bold()
                
                Text("Works how you'd expect. Swipe, pinch, and rotate to move around. Tap on a restroom pin to see more information.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Use the buttons in the top right to focus on your location (if enabled), switch between 2D and 3D, and re-orient to North (if rotated).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                HStack{
                    Image(systemName: .locationIcon)
                    Image(systemName: .threeDimentionIcon)
                    Image(systemName: .dottedCircleIcon)
                        .overlay { Text("N").font(.footnote) }
                        .overlay(alignment: .top) {
                            Image(systemName: .triangleIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 4)
                                .foregroundStyle(.red)
                        }
                }
                .font(.title3)
            }
        }
    }
}

#if DEBUG
#Preview {
    Color.yellow
        .sheet(isPresented: .constant(true)) {
            MapTutorialView()
                .modifier(TutorialScreenModifier(id: .map))
        }
}
#endif
