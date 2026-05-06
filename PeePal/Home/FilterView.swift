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
                        .background {
                            Circle()
                                .fill(Color.unisex)
                                .padding(10)
                                .shadow(color: .unisex, radius: 5)
                                .shadow(color: .unisex, radius: 5)
                                .shadow(color: .unisex, radius: 5)
                        }
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
                        .background {
                            Circle()
                                .fill(Color.accessible)
                                .padding(10)
                                .shadow(color: .accessible, radius: 5)
                                .shadow(color: .accessible, radius: 5)
                                .shadow(color: .accessible, radius: 5)
                        }
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
                        .background {
                            Circle()
                                .fill(Color.changingTable)
                                .padding(10)
                                .shadow(color: .changingTable, radius: 5)
                                .shadow(color: .changingTable, radius: 5)
                                .shadow(color: .changingTable, radius: 5)
                        }
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

#Preview {
    Color.yellow
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: .constant(true))  {
            FilterView()
                .presentationDetents([.lowHalf])
        }
}
