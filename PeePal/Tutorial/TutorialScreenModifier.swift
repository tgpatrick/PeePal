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
        HStack {
            Spacer()
            content
            Spacer()
        }
        .safeAreaPadding(.bottom, 100)
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
