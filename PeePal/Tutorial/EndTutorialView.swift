//
//  EndTutorialView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/21/26.
//

import SwiftUI

struct EndTutorialView: View {
    var body: some View {
        VStack {
            Image(systemName: "fireworks")
                .modifier(TutorialImageModifer())
            
            VStack(spacing: .tutorialContentSpacing) {
                Text("Thats it!")
                    .tutorialTitleStyle()
                
                Text("Hope you enjoy using PeePal and that you find some good spots. Good luck!")
                    .tutorialSubtitleStyle()
                
                Text("Remember, you can view the tutorial any time from the settings. And there's also a bunch of other useful stuff in there!")
                    .tutorialBodyStyle()
            }
        }
    }
}

#if DEBUG
#Preview {
    EndTutorialView()
}
#endif
