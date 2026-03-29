//
//  TitledBoxView.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/7/24.
//

import SwiftUI

struct TitledBoxView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.title2)
            HStack {
                Text(content)
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThickMaterial)
            )
        }
    }
}

#Preview {
    TitledBoxView(title: "Title", content: "This is some content. Hello, World!")
}
