//
//  SearchTutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/21/26.
//

import SwiftUI

struct SearchTutorialView: View {
    var body: some View {
        VStack {
            Image(systemName: .searchCircleIcon)
                .modifier(TutorialImageModifer())
            
            VStack(spacing: .tutorialContentSpacing) {
                Text("Search")
                    .tutorialTitleStyle()
                
                Text("Because sometimes swiping gets exhausing")
                    .tutorialSubtitleStyle()
                
                Text("As you search, you'll see two kinds of results, \"Map Results\" from Apple Maps and \"Restroom Results\" from Refuge Restrooms. Restrooms you've seen before on the map will load quickly, but new results will take a moment.")
                    .tutorialBodyStyle()
                
                Text("Tap a result to focus it on the map. Apple Maps results are only there temporarily to save you scrolling over there, but restroom results will stick around.")
                    .tutorialBodyStyle()
            }
        }
    }
}

#if DEBUG
#Preview {
    SearchTutorialView()
}
#endif
