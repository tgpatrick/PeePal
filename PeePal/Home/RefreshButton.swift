//
//  RefreshButton.swift
//  PeePal
//
//  Created by Thomas Patrick on 5/6/26.
//

import SwiftUI

struct RefreshButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Refresh here")
                .bold()
        }
        .modifier(GlassyOrProminentButton())
        .tint(.unisex)
        .zIndex(2)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#if DEBUG
#Preview {
    @Previewable @State var showButton: Bool = false
    
    Color.gray.overlay {
        VStack {
            Button("Show button", action: {
                withAnimation {
                    showButton.toggle()
                }
            })
            Spacer()
            if showButton {
                RefreshButton {}
            }
        }
        .frame(height: 250)
    }
}
#endif
