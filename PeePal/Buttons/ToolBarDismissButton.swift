//
//  ToolBarDismissButton.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/20/26.
//

import SwiftUI

struct ToolBarDismissButton: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        Button {
            dismiss()
            if let onDismiss {
                onDismiss()
            }
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(height: 30)
                .fontWeight(.heavy)
        }
        .buttonStyle(GlassyToolbarButton())
    }
}
