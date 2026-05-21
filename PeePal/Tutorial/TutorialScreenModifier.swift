//
//  TutorialScreenModifier.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/20/26.
//

import SwiftUI

struct TutorialScreenModifier: ViewModifier {
    let id: TutorialPage
    
    func body(content: Content) -> some View {
        VStack {
            HStack {
                Spacer()
                content
                Spacer()
            }
            .safeAreaPadding(.top, 50)
            .safeAreaPadding(.bottom, 100) // For the button
        }
        .background(.ultraThinMaterial)
        .id(id)
    }
}

#if DEBUG
#Preview {
    Color.yellow
        .sheet(isPresented: .constant(true)) {
            TutorialView()
        }
}
#endif
