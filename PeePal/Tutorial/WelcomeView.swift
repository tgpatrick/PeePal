//
//  WelcomeView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/20/26.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image(.icon)
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            Gradient(colors: [.accentColorLight, .accentColor])
                        )
                )
                .accessibilityHidden(true)
            
            VStack(spacing: .tutorialContentSpacing) {
                Text("Welcome to PeePal!")
                    .tutorialTitleStyle()
                
                Text("We help you know where you can go")
                    .tutorialSubtitleStyle()
                
                Text("And don't worry if you're in a hurry. You can review this tutorial any time from the settings.")
                    .tutorialBodyStyle()
            }
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView()
}
#endif
