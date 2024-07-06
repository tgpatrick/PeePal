//
//  SheetView.swift
//  PeePal
//
//  Created by Thomas Patrick on 7/5/24.
//

import SwiftUI

struct SheetView: View {
    @Binding var searchField: String
    @Binding var selectedCluster: RestroomCluster?

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $searchField)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(
                            Color.secondary.opacity(0.25)
                        )
                )
                .padding()
                Spacer()
            }
            if let selectedCluster {
                ZStack(alignment: .topTrailing) {
                    List(selectedCluster.restrooms) { restroom in
                        Text(restroom.name ?? "")
                    }
                    Button(action: {
                        _selectedCluster.wrappedValue = nil
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .foregroundStyle(.regularMaterial)
                            .frame(height: 30)
                            .background(
                                Circle()
                                    .fill(Color.secondary.opacity(0.75))
                            )
                            .padding()
                            .fontWeight(.heavy)
                    })
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(.ultraThickMaterial)
        .background(Color.accentColor.opacity(0.5))
        .animation(.easeInOut, value: selectedCluster)
    }
}

#Preview {
    Color.indigo
        .sheet(isPresented: .constant(true)) {
            SheetView(
                searchField: .constant(""),
                selectedCluster: .constant(RestroomCluster(restrooms: [exampleRestroom])))
            .interactiveDismissDisabled()
        }
}

#Preview {
    Color.indigo
        .sheet(isPresented: .constant(true)) {
            SheetView(
                searchField: .constant(""),
                selectedCluster: .constant(nil))
            .interactiveDismissDisabled()
        }
}
