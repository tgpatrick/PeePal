//
//  AvailabilityBadgeView.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/20/26.
//

import SwiftUI

struct AvailabilityBadgeView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let imageResource: ImageResource
    private let isAvailable: Bool
    private let shouldInvert: Bool
    
    init(for imageResource: ImageResource, isAvailable: Bool, shouldInvert: Bool = true) {
        self.imageResource = imageResource
        self.isAvailable = isAvailable
        self.shouldInvert = shouldInvert
    }
    
    var body: some View {
        imageInvertedIfDark(image: Image(imageResource))
            .padding(10)
            .frame(width: 50, height: 50)
            .opacity(isAvailable ? 1 : 0.1)
    }
    
    private func imageInvertedIfDark(image: Image) -> some View {
        Group {
            if colorScheme == .dark && shouldInvert {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .colorInvert()
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

#Preview {
    AvailabilityBadgeView(for: .unisex, isAvailable: true)
    AvailabilityBadgeView(for: .accessible, isAvailable: true)
    AvailabilityBadgeView(for: .changingTable, isAvailable: true)
}
