//
//  AvailabilityBadgeView.swift
//  PeePal
//
//  Created by Thomas Patrick on 4/20/26.
//

import SwiftUI

struct AvailabilityBadgeView: View {
    let restroom: Restroom
    
    var body: some View {
        HStack(spacing: 0) {
            IndividualAvailabilityBadgeView(for: .unisex, isAvailable: restroom.unisex)
            IndividualAvailabilityBadgeView(for: .accessible, isAvailable: restroom.accessible)
            IndividualAvailabilityBadgeView(for: .changingTable, isAvailable: restroom.changingTable)
        }
        .background(badgesBackground)
    }
    
    private var badgesBackground: some View {
        Rectangle()
            .foregroundStyle(.ultraThinMaterial)
            .background(
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(
                            Color(.unisex).opacity(restroom.unisex ? 1 : 0.1)
                        )
                    Rectangle()
                        .foregroundStyle(
                            Color(.accessible).opacity(restroom.accessible ? 1 : 0.1)
                        )
                        .zIndex(2)
                    Rectangle()
                        .foregroundStyle(
                            Color(.accessible).opacity(restroom.accessible ? 1 : 0.1)
                        )
                        .zIndex(2)
                    Rectangle()
                        .foregroundStyle(
                            Color(.changingTable).opacity(restroom.changingTable ? 1 : 0.1)
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct IndividualAvailabilityBadgeView: View {
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

#if DEBUG
#Preview {
    AvailabilityBadgeView(restroom: exampleRestroom)
}
#endif
