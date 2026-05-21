//
//  RestroomTutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/21/26.
//

import SwiftUI

struct RestroomTutorialView: View {
    var body: some View {
        VStack {
            Image(systemName: .mapPinCircleIcon)
                .tutorialImageStyle()
            
            VStack(spacing: .tutorialContentSpacing) {
                Text("Restrooms")
                    .tutorialTitleStyle()
                
                Text("Everyone should feel safe using the restroom. That's why PeePal uses data from Refuge Restrooms to tell you important extra information.")
                    .tutorialSubtitleStyle()
                
                Text("Each restroom is marked as having a unisex, accessible, and/or changing table option. You can limit the map to show only restrooms that match your preferences using the filter button:")
                    .tutorialBodyStyle()
                Image(systemName: .filterCircleIcon)
                    .font(.largeTitle)
                
                Text("Additionally, you can tell if a restroom includes a unisex and/or accessible option by the colors of its pin. Here, you see pins with purple for unisex, blue for accessible, both, and neither:")
                    .tutorialBodyStyle()
                HStack {
                    RestroomAnnotation(
                        selection: .constant(nil),
                        restroom: unisexRestroom
                    )
                    RestroomAnnotation(
                        selection: .constant(nil),
                        restroom: accessibleRestroom
                    )
                    RestroomAnnotation(
                        selection: .constant(nil),
                        restroom: exampleRestroom
                    )
                    RestroomAnnotation(
                        selection: .constant(nil),
                        restroom: boringRestroom
                    )
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    RestroomTutorialView()
}
#endif
