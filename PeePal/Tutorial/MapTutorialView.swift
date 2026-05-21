//
//  MapTutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/21/26.
//

import SwiftUI

struct MapTutorialView: View {
    var body: some View {
        VStack {
            Image(systemName: .mapCircleIcon)
                .tutorialImageStyle()
            
            VStack(spacing: .tutorialContentSpacing) {
                Text("The map")
                    .tutorialTitleStyle()
                
                Text("Works how you'd expect. Swipe, pinch, and rotate to move around. Tap on a restroom pin to see more information.")
                    .tutorialSubtitleStyle()
                
                Text("Use the buttons in the top right to focus on your location (if enabled), switch between 2D and 3D, and re-orient to North (if rotated).")
                    .tutorialBodyStyle()
                
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
