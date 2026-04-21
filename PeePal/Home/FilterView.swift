//
//  FilterView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/12/20.
//

import SwiftUI

struct FilterView: View {
    @AppStorage("accessFilter") private var accessFilter: Bool = false
    @AppStorage("unisexFilter") private var unisexFilter: Bool = false
    @AppStorage("tableFilter") private var tableFilter: Bool = false
    
    var body: some View {
        NavigationStack {
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
                    Toggle("Unisex Available", isOn: $unisexFilter)
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
                    Toggle("ADA Accessible", isOn: $accessFilter)
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
                    Toggle("Changing Table Available", isOn: $tableFilter)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 15)
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
