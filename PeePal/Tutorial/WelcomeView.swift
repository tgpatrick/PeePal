//
//  WelcomeView.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/20/26.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
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
            
            VStack(spacing: 8) {
                Text("Welcome to PeePal!")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                
                Text("We help you know where you can go")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("And don't worry if you're in a hurry. You can review this tutorial any time from the settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView()
}
#endif
