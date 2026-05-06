//
//  FilterView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct FilterView: View {
    @AppStorage(Filter.accessible.rawValue) private var accessFilter: Bool = false
    @AppStorage(Filter.unisex.rawValue) private var unisexFilter: Bool = false
    @AppStorage(Filter.changingTable.rawValue) private var tableFilter: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack(spacing: 10) {
                        AvailabilityBadgeView(
                            for: .unisex,
                            isAvailable: true,
                            shouldInvert: false
                        )
                        .colorCircleShadow(.unisex)
                        Toggle("Unisex", isOn: $unisexFilter)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    HStack {
                        AvailabilityBadgeView(
                            for: .accessible,
                            isAvailable: true,
                            shouldInvert: false
                        )
                        .colorCircleShadow(.accessible)
                        Toggle("Accessible", isOn: $accessFilter)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    HStack {
                        AvailabilityBadgeView(
                            for: .changingTable,
                            isAvailable: true,
                            shouldInvert: false
                        )
                        .colorCircleShadow(.changingTable)
                        Toggle("Changing Table", isOn: $tableFilter)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 15)
            }
            .toolbar {
                ToolBarDismissButton()
            }
            .navigationTitle("Filters")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}

#if DEBUG
#Preview {
    Color.yellow
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: .constant(true))  {
            FilterView()
                .presentationDetents([.lowHalf])
        }
}
#endif
